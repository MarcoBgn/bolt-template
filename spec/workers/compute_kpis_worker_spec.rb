# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ComputeKpisWorker, type: :job do
  let(:channel_id) { 'org-fbba' }

  describe 'Constants' do
    it { expect(described_class::BATCH_PERIOD).to eq((ENV['KPIS_BATCH_PERIOD'] || '60').to_i.seconds) }
  end

  describe '.cache_key(channel_id)' do
    subject { described_class.cache_key(channel_id) }
    it { is_expected.to eq('workers/compute_kpis/org-fbba') }
  end

  describe '.batch_for(channel_id, saved_entities)' do
    let(:saved_entities) { %w(invoices journals) }
    let(:job) { double(described_class, perform_later: true) }

    subject { described_class.batch_for(channel_id, saved_entities) }

    before { allow(described_class).to receive(:set).and_return(job) }
    before { stub_const("#{described_class}::BATCH_PERIOD", 2.minutes) }

    it 'batches the updated entities in cache' do
      REDIS_POOL.with do |redis|
        expect { subject }.to change {
          redis.lrange("#{described_class.cache_key(channel_id)}/entities", 0, -1)
        }.to(saved_entities)
      end
    end

    it 'updates the queuing timer in cache' do
      REDIS_POOL.with do |redis|
        expect { subject }.to change {
          redis.get("#{described_class.cache_key(channel_id)}/enqueue_until")
        }.to((Time.zone.now + 2.minutes).to_s)
      end
    end

    it 'enqueues the worker' do
      expect(described_class).to receive(:set).with(wait: 2.minutes)
      expect(job).to receive(:perform_later).with(channel_id)
      subject
    end

    context 'when the worker is already batched' do
      before do
        REDIS_POOL.with do |redis|
          redis.set("#{described_class.cache_key(channel_id)}/enqueue_until", Time.zone.now + 1.minute)
          redis.rpush("#{described_class.cache_key(channel_id)}/entities", 'accounts')
        end
      end

      it 'updates the queuing timer in cache' do
        REDIS_POOL.with do |redis|
          expect { subject }.to change {
            redis.get("#{described_class.cache_key(channel_id)}/enqueue_until")
          }.to((Time.zone.now + 2.minutes).to_s)
        end
      end

      it 'updates the updated entities in cache' do
        REDIS_POOL.with do |redis|
          expect { subject }.to change {
            redis.lrange("#{described_class.cache_key(channel_id)}/entities", 0, -1)
          }.to(%w(accounts) + saved_entities)
        end
      end

      it 'does not enqueue the worker again' do
        expect(described_class).to_not receive(:set)
        expect(job).to_not receive(:perform_later)
        subject
      end
    end
  end

  describe '#perform' do
    let(:endpoint) { 'my_kpi' }
    let(:settings) { { 'a' => 'setting' } }
    let(:recipients) { [{ 'id' => 1, 'email' => 'email' }, { 'id' => 1, 'email' => 'email' }] }
    let(:alerts) { [{ 'recipients' => recipients }] }
    let(:kpi) { double(:kpi, dispatch_alerts: true) }
    let(:job) { described_class.new }

    subject { job.perform(channel_id) }

    before do
      stub_const('Kpis::Base::KPIS_LIST', 'kpis/my_kpi' => double(:string, constantize: double(:kpi, new: kpi)))
      stub_const("#{described_class}::BATCH_PERIOD", 2.minutes)

      allow(Clients::MnoHub).to receive(:get_kpis).and_return(
        OpenStruct.new(
          success?: true,
          parsed_response: {
            'data' => [
              {
                'endpoint' => "kpis/#{endpoint}",
                'settings' => settings,
                'alerts' => alerts
              }
            ]
          }
        )
      )
    end

    RSpec.shared_examples_for "#{described_class}: ignored kpi" do
      it 'does not dispatch the kpi alerts' do
        expect(kpi).to_not receive(:dispatch_alerts)
        subject
      end
    end

    RSpec.shared_examples_for "#{described_class}: job execution" do
      it 'fetches the KPIs list from MnoHub' do
        expect(Clients::MnoHub).to receive(:get_kpis).once
        subject
      end

      it 'dispatches the alerts for the valid kpis' do
        expect(kpi).to receive(:dispatch_alerts)
        subject
      end

      context 'with invalid endpoint' do
        it_behaves_like "#{described_class}: ignored kpi" do
          let(:endpoint) { 'unknown_kpi' }
        end
      end

      context 'with no setting' do
        it_behaves_like "#{described_class}: ignored kpi" do
          let(:settings) { {} }
        end
      end

      context 'with no alert' do
        it_behaves_like "#{described_class}: ignored kpi" do
          let(:alerts) { [] }
        end
      end

      context 'with no alert recipient' do
        it_behaves_like "#{described_class}: ignored kpi" do
          let(:recipients) { [] }
        end
      end

      context 'when the response from mnohub is unsuccessful' do
        before { allow(Clients::MnoHub).to receive(:get_kpis).and_return(OpenStruct.new(success?: false)) }
        it 'logs a warning' do
          expect(Rails.logger).to receive(:warn)
          subject
        end
      end
    end

    it_behaves_like "#{described_class}: job execution"

    context 'when the worker is batched' do
      let(:queuing_timer) { Time.zone.now + 1.minute }

      before do
        REDIS_POOL.with do |redis|
          redis.set("#{described_class.cache_key(channel_id)}/enqueue_until", queuing_timer)
          redis.rpush("#{described_class.cache_key(channel_id)}/entities", 'accounts')
        end
      end

      context 'when the time limit is not passed yet' do
        it 'enqueues the job for later execution' do
          allow(job).to receive(:retry_job).and_return('job enqueued')
          expect(job).to receive(:retry_job).with(wait: 2.minutes)
          is_expected.to eq('job enqueued')
        end
      end

      context 'when the time limit is passed' do
        let(:queuing_timer) { Time.zone.now - 1.minute }

        it_behaves_like "#{described_class}: job execution"

        it 'wipes the queuing timer from the cache' do
          REDIS_POOL.with do |redis|
            expect { subject }.to change {
              redis.get("#{described_class.cache_key(channel_id)}/enqueue_until")
            }.to(nil)
          end
        end

        it 'wipes the entities from the cache' do
          REDIS_POOL.with do |redis|
            expect { subject }.to change {
              redis.lrange("#{described_class.cache_key(channel_id)}/entities", 0, -1)
            }.to([])
          end
        end
      end
    end
  end
end

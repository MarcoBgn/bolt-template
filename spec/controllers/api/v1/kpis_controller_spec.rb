# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::V1::KpisController, type: :controller do
  let(:errors) { [] }
  let(:invalid?) { false }
  let(:kpi) do
    double(
      Kpis::MyKpi,
      title: 'My Kpi!!',
      invalid?: invalid?,
      errors: errors,
      render: 'rendered kpi!'
    )
  end

  let(:watchables) { %i(a_watchable) }
  let(:attachables) { %w(an_attachable) }

  before do
    stub_const('Api::V1::KpisController::KPIS_LIST', %w(my_kpi))
    stub_const('Kpis::MyKpi', Kpis::Base)
    stub_const('Kpis::MyKpi::WATCHABLES', watchables)
    stub_const('Kpis::MyKpi::ATTACHABLES', attachables)
    allow(Kpis::MyKpi).to receive(:new).and_return(kpi)
  end

  describe '#index' do
    subject { get :index }
    it_behaves_like 'unauthenticated action'

    it 'returns the list of kpis with their supported watchables & attachables' do
      subject
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['kpis']).to eq(
        [
          {
            'name' => 'My Kpi!!',
            'endpoint' => 'kpis/my_kpi',
            'watchables' => watchables.map(&:to_s),
            'attachables' => attachables
          }
        ]
      )
    end
  end

  describe '#show' do
    let(:endpoint) { 'my_kpi' }
    let(:watchable) { 'a_watchable' }
    let(:targets) { { watchable => [{ 'min' => '100' }] } }
    let(:metadata) { { 'organization_ids' => ['org-fbba'] } }
    let(:params) { { 'endpoint' => endpoint, 'watchable' => watchable, 'metadata' => metadata, 'excluded' => 'param' } }
    let(:authorised_params) { params.except('excluded', 'metadata').merge('settings' => params['metadata']) }

    subject { get :show, params: params }

    it_behaves_like 'warden authenticated action'

    context 'when the request is authenticated' do
      before { login_as(double(:user)) }

      it 'instantiates a kpi with the params' do
        construction_params = authorised_params.deep_symbolize_keys
        expect(Kpis::MyKpi).to receive(:new).with(construction_params)
        subject
      end

      it_behaves_like 'success response', 'rendered kpi!'

      context 'when targets are set' do
        before { params.merge!('targets' => targets) }

        it 'instantiates a kpi with the params' do
          construction_params = authorised_params.merge(targets: targets).deep_symbolize_keys
          expect(Kpis::MyKpi).to receive(:new).with(construction_params)
          subject
        end
      end

      context 'when the endpoint is not valid' do
        let(:endpoint) { 'anything' }
        it_behaves_like 'error response', 'Kpi endpoint does not exist'
      end

      context 'when the watchable is not valid' do
        let(:watchable) { 'anything' }
        it_behaves_like 'error response', 'Kpi watchable does not exist'
      end

      context 'when the kpi has errors' do
        let(:errors) { double(:error, full_messages: ['Error for this kpi']) }
        let(:invalid?) { true }
        it_behaves_like 'error response', 'Error for this kpi'
      end
    end
  end
end

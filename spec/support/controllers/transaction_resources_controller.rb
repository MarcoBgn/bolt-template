# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples_for 'Api::V1::ResourcesController - Transaction' do |trx_type|
  include_context 'Api::V1::ResourcesController headers'

  it_behaves_like 'Api::V1::ResourcesController'

  describe 'GET #index' do
    subject { get :index, params: params }

    let(:params) { {} }
    let(:company1) { create(:company, channel_id: 'org-1') }
    let(:company2) { create(:company, channel_id: 'org-2') }
    let(:company3) { create(:company, channel_id: 'org-3') }
    let!(:trx1) { create(trx_type, company: company1, due_date: Time.zone.parse('2015-03-30')) }
    let!(:trx2) { create(trx_type, company: company2, due_date: Time.zone.parse('2015-03-31')) }
    let!(:trx3) { create(trx_type, company: company3, due_date: Time.zone.parse('2015-04-01')) }

    before { login_as(double(:user)) }

    it 'returns all the transactions' do
      is_expected.to have_http_status(:success)
      expect(JSON.parse(response.body)['data'].count).to eq(3)
    end

    context 'with filter on :channel_id' do
      let(:params) { { filter: { channel_id: [company1.channel_id, company2.channel_id] } } }

      it 'returns only the transactions belonging to the corresponding companies' do
        is_expected.to have_http_status(:success)
        trxs = JSON.parse(response.body)['data']
        expect(trxs.count).to eq(2)
        trx_ids = trxs.map { |d| d['id'] }
        expect(trx_ids).to include(trx1.id)
        expect(trx_ids).to include(trx2.id)
        expect(trx_ids).not_to include(trx3.id)
      end
    end

    context 'with filter on :due_date' do
      let(:operator) { nil }
      let(:date) { '2015-03-31' }
      let(:params) { { filter: { due_date: [operator, date].compact.join(' ') } } }

      context 'with only a date' do
        it 'returns only the transactions that strictly match the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(1)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).not_to include(trx1.id)
          expect(trx_ids).to include(trx2.id)
          expect(trx_ids).not_to include(trx3.id)
        end
      end

      context 'with an unknown operator + date' do
        let(:operator) { '?' }
        it { is_expected.to have_http_status(:bad_request) }
      end

      context 'with gt + date' do
        let(:operator) { 'gt' }

        it 'returns only the transactions strictly greater than the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(1)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).not_to include(trx1.id)
          expect(trx_ids).not_to include(trx2.id)
          expect(trx_ids).to include(trx3.id)
        end
      end

      context 'with gte + date' do
        let(:operator) { 'gte' }

        it 'returns only the transactions greater than or equal to the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(2)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).not_to include(trx1.id)
          expect(trx_ids).to include(trx2.id)
          expect(trx_ids).to include(trx3.id)
        end
      end

      context 'with eq + date' do
        let(:operator) { 'eq' }

        it 'returns only the transactions that strictly match the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(1)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).not_to include(trx1.id)
          expect(trx_ids).to include(trx2.id)
          expect(trx_ids).not_to include(trx3.id)
        end
      end

      context 'with lt + date' do
        let(:operator) { 'lt' }

        it 'returns only the transactions strictly lesser than the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(1)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).to include(trx1.id)
          expect(trx_ids).not_to include(trx2.id)
          expect(trx_ids).not_to include(trx3.id)
        end
      end

      context 'with lte + date' do
        let(:operator) { 'lte' }

        it 'returns only the transactions lesser than or equal to the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(2)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).to include(trx1.id)
          expect(trx_ids).to include(trx2.id)
          expect(trx_ids).not_to include(trx3.id)
        end
      end

      context 'with ne + date' do
        let(:operator) { 'ne' }

        it 'returns only the transactions that do not match the due date' do
          is_expected.to have_http_status(:success)
          trxs = JSON.parse(response.body)['data']
          expect(trxs.count).to eq(2)
          trx_ids = trxs.map { |d| d['id'] }
          expect(trx_ids).to include(trx1.id)
          expect(trx_ids).not_to include(trx2.id)
          expect(trx_ids).to include(trx3.id)
        end
      end
    end
  end
end

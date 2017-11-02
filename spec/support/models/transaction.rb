# frozen_string_literal: true
require 'rails_helper'

# Shared Example for Transaction models (Invoice, Bill...)
RSpec.shared_examples_for 'a Transaction model' do
  let(:channel_id) { 'org-fbci' }
  let!(:company) { create(:company, id: 'comp-1', channel_id: channel_id) }

  describe 'Associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:journals).dependent(:destroy) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:company) }

    context 'when the currency is not defined' do
      let(:invoice) { create(:invoice, company: company) }
      it 'takes the company currency' do
        expect(invoice.currency).to eq(company.currency)
      end
    end
  end

  describe '.mapped_fields' do
    subject { described_class.mapped_fields }
    it { is_expected.to eq %w(amount currency) }
  end

  it_behaves_like 'a BaseEntity model' do
    let(:entities_array) do
      [
        {
          'id' => '4e2893a0-2183-0135-4485-7caa147a84c2',
          'title' => 'GB1-White',
          'transaction_number' => 'ORC1039',
          'transaction_date' => '2017-05-23T00:00:00Z',
          'due_date' => '2017-06-10T00:00:00Z',
          'status' => 'AUTHORISED',
          'type' => transaction_type,
          'balance' => 234.0,
          'deposit' => 0.0,
          'amount' => {
            'total_amount' => 234.0,
            'net_amount' => 212.73,
            'tax_amount' => 21.27,
            'tax_rate' => 10.0,
            'currency' => 'AUD'
          },
          'currency_rate' => 1.0,
          'organization_id' => '3eaa1380-2183-0135-4283-7caa147a84c2',
          'person_id' => '3eb888d0-2183-0135-4285-7caa147a84c2',
          'tax_calculation' => 'TAX_INCLUSIVE',
          'billing_address' => {
            'attention' => 'Club Secretary',
            'line1' => 'P O Box 3354',
            'line2' => 'South Mailing Centre',
            'city' => 'Ridge Heights',
            'region' => 'Madeupville',
            'postal_code' => 'MVL 6001',
            'country' => 'Australia'
          },
          'shipping_address' => {

          },
          'lines' => [
            {
              'id' => '59238d5091a4053a5bc176bc',
              'line_number' => 1,
              'description' => 'Courier charge',
              'status' => 'ACTIVE',
              'quantity' => 1.0,
              'unit_price' => {
                'total_amount' => 10.0,
                'net_amount' => 9.09,
                'tax_amount' => 0.91,
                'tax_rate' => 10.0
              },
              'total_price' => {
                'total_amount' => 10.0,
                'net_amount' => 9.09,
                'tax_amount' => 0.91,
                'tax_rate' => 10.0
              },
              'tax_code_id' => '359b15d0-2183-0135-4071-7caa147a84c2',
              'account_id' => '370fb8a0-2183-0135-40c2-7caa147a84c2'
            },
            {
              'id' => '59238d5091a4053a5bc176be',
              'line_number' => 2,
              'description' => 'Golf balls - white single',
              'status' => 'ACTIVE',
              'quantity' => 40.0,
              'unit_price' => {
                'total_amount' => 5.6,
                'net_amount' => 5.09,
                'tax_amount' => 0.51,
                'tax_rate' => 10.0
              },
              'total_price' => {
                'total_amount' => 224.0,
                'net_amount' => 203.64,
                'tax_amount' => 20.36,
                'tax_rate' => 10.0
              },
              'tax_code_id' => '35b4a1f0-2183-0135-4081-7caa147a84c2',
              'account_id' => '36b4d480-2183-0135-4096-7caa147a84c2',
              'item_id' => '4209f0f0-2183-0135-42bf-7caa147a84c2'
            }
          ],
          'created_at' => '2017-05-23T01:16:00Z',
          'updated_at' => '2017-05-23T01:16:00Z'
        }
      ]
    end

    describe '.map(channel_id, entity_hash)' do
      subject { described_class.map(channel_id, formatted_hash) }

      it 'returns the base attributes' do
        expect(subject[:id]).to eq('4e2893a0-2183-0135-4485-7caa147a84c2')
        expect(subject[:title]).to eq('GB1-White')
        expect(subject[:transaction_number]).to eq('ORC1039')
        expect(subject[:status]).to eq('AUTHORISED')
        expect(subject[:balance]).to eq(234.0)
        expect(subject[:currency_rate]).to eq(1.0)
        expect(subject[:transaction_date]).to eq('2017-05-23T00:00:00Z')
        expect(subject[:due_date]).to eq('2017-06-10T00:00:00Z')
      end

      it 'maps the total_amount to :amount' do
        expect(subject[:amount]).to eq(234.0)
      end

      it 'maps the amount currency to :currency' do
        expect(subject[:currency]).to eq('AUD')
      end

      context 'when the total amount is nil' do
        before { formatted_hash[:amount][:total_amount] = nil }

        it 'maps the net_amount to :amount instead' do
          expect(subject[:amount]).to eq(212.73)
        end
      end

      it 'fetches the parent company and associates it to the account' do
        parent_company_stub = Utility::ParentEntity.new(:company, channel_id)
        expect(Utility::ParentEntity).to receive(:new).with(:company, channel_id).and_return(parent_company_stub)
        expect(parent_company_stub).to receive(:fetch).and_call_original
        expect(subject).to include(company_id: company.id)
      end
    end
  end
end

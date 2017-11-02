# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Api::V1::NotificationsController, type: :controller do
  describe '#create' do
    let(:channel_id) { 'org-abcd' }
    let(:examples) do
      [
        { 'id' => 'inv-1', 'type' => 'CUSTOMER' },
        { 'id' => 'bil-1', 'type' => 'SUPPLIER' }
      ]
    end
    let(:params) do
      {
        'channel_id' => channel_id,
        'entities' => {
          'example1' => [{ 'id' => 'comp-1' }],
          'example2' => [{ 'id' => 'acc-1' }],
          'examples' => examples
        },
        'unauthorised' => 'param'
      }
    end

    subject { post :create, params: params }

    it_behaves_like 'warden authenticated action'

    context 'when the request is authenticated' do
      before do
        # login_as(double(:user))
        # allow(ExampleWorker).to receive(:perform_later).and_return(true)
      end
      # TODO: to be implemented with Bolt specific workers
      # it 'enqueues a job to process each entities group' do
      #   expect(ExampleWorker).to receive(:perform_later).with(channel_id, 'examples', [{ 'id' => 'comp-1' }])
      #   subject
      # end
      #
      # it { is_expected.to have_http_status(:ok) }
    end
  end
end

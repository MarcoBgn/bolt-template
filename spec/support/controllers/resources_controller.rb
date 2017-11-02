# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_context 'Api::V1::ResourcesController headers' do
  before do
    request.env['HTTP_ACCEPT'] = JSONAPI::MEDIA_TYPE
    request.env['CONTENT_TYPE'] = JSONAPI::MEDIA_TYPE
  end
end

RSpec.shared_examples_for 'Api::V1::ResourcesController' do
  describe 'GET #index' do
    subject { get :index }

    it_behaves_like 'warden authenticated action'

    context 'when the request is authenticated' do
      before { login_as(double(:user)) }

      it { is_expected.to have_http_status(:success) }
    end
  end
end

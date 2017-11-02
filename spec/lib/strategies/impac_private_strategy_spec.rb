# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ImpacPrivateStrategy do
  let(:basic_auth) { 'Basic Og==' }
  let(:env) do
    {
      'HTTP_VERSION' => '1.1',
      'REQUEST_METHOD' => 'GET',
      'action_dispatch.request.path_parameters' => {},
      'action_dispatch.request.request_parameters' => {},
      'HTTP_AUTHORIZATION' => basic_auth
    }
  end

  subject { Warden::Strategies[:impac_private].new(env) }

  describe 'valid?' do
    it { expect(subject.valid?).to eq(false) }

    context 'with incomplete basic_auth credentials' do
      let(:basic_auth) do
        key = ENV['IMPAC_KEY']
        ActionController::HttpAuthentication::Basic.encode_credentials(key, '')
      end
      it { expect(subject.valid?).to eq(false) }
    end

    context 'with valid basic_auth credentials' do
      let(:basic_auth) do
        key = ENV['IMPAC_KEY']
        secret = ENV['IMPAC_SECRET']
        ActionController::HttpAuthentication::Basic.encode_credentials(key, secret)
      end
      it { expect(subject.valid?).to eq(true) }
    end
  end

  describe 'authenticate!' do
    before { subject._run! }

    it 'rejects the authentication' do
      expect(subject.user).to be_falsey
    end

    context 'with valid basic_auth credentials' do
      let(:basic_auth) do
        key = ENV['IMPAC_KEY']
        secret = ENV['IMPAC_SECRET']
        ActionController::HttpAuthentication::Basic.encode_credentials(key, secret)
      end

      it 'accepts the authentication' do
        expect(subject.user).to be_truthy
      end
    end
  end
end

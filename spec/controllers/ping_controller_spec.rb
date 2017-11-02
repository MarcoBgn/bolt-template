# frozen_string_literal: true
require 'rails_helper'
RSpec.describe PingController, type: :controller do
  describe '#index' do
    subject { get :index }
    it { is_expected.to have_http_status(200) }
  end
end

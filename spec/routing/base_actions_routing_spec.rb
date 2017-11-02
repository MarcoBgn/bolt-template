# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'routing to base actions', type: :routing do
  it 'routes to ping#create' do
    expect(get('/ping')).to route_to('ping#index')
  end
end

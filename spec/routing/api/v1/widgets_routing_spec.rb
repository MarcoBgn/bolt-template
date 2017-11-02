# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'routing to widgets', type: :routing do
  it 'routes to #show' do
    expect(get('/api/v1/widgets/my_endpoint')).to route_to('api/v1/widgets#show', endpoint: 'my_endpoint')
  end

  it 'routes to #index' do
    expect(get('/api/v1/widgets')).to route_to('api/v1/widgets#index')
  end
end

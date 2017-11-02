# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'routing to kpis', type: :routing do
  it 'routes to #index' do
    expect(get('/api/v1/kpis')).to route_to('api/v1/kpis#index')
  end
  it 'routes to #show' do
    params = { endpoint: 'an_endpoint', watchable: 'a_watchable' }
    expect(get('/api/v1/kpis/an_endpoint/a_watchable')).to route_to('api/v1/kpis#show', params)
  end
end

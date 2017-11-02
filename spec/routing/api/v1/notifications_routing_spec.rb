# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'routing to notifications', type: :routing do
  it 'routes to #create' do
    expect(post('/api/v1/notifications')).to route_to('api/v1/notifications#create')
  end
end

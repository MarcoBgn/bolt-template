# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples_for 'error response' do |error_message, special_params|
  it 'renders an error and the filtered params' do
    returned_params = authorised_params.merge(special_params.to_h)
    is_expected.to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['errors']).to eq([error_message])
    expect(JSON.parse(response.body)['params']).to eq(returned_params)
  end
end

RSpec.shared_examples_for 'success response' do |render_result|
  it 'renders the object output and the filtered params' do
    is_expected.to have_http_status(:success)
    expect(JSON.parse(response.body)[endpoint]).to eq(render_result)
    expect(JSON.parse(response.body)['params']).to eq(authorised_params)
  end
end

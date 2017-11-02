# frozen_string_literal: true
require 'rails_helper'

# Shared Example for controller using warden authentication
RSpec.shared_examples_for 'warden authenticated action' do
  it 'uses warden strategies to authenticate the request' do
    warden = double(:warden, authenticate!: nil)
    expect_any_instance_of(described_class).to receive(:warden).and_return(warden)
    expect(warden).to receive(:authenticate!)
    subject
  end
end

RSpec.shared_examples_for 'unauthenticated action' do
  it 'does not need to be authenticated' do
    expect_any_instance_of(described_class).to_not receive(:warden)
    subject
  end
end

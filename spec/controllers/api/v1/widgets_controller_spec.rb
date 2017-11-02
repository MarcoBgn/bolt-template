# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::V1::WidgetsController, type: :controller do
  let(:errors) { [] }
  let(:invalid?) { false }
  let(:widget) do
    double(
      Widgets::MyWidget,
      supported_layouts: ['chart'],
      errors: errors,
      invalid?: invalid?,
      render: 'rendered widget!',
      compute: true,
      fill_layouts: true
    )
  end

  before do
    stub_const('Api::V1::WidgetsController::WIDGETS_LIST', ['my_widget'])
    stub_const('Widgets::MyWidget', Widgets::Base)
    allow(Widgets::MyWidget).to receive(:new).and_return(widget)
  end

  describe '#index' do
    subject { get :index }

    it_behaves_like 'unauthenticated action'

    it 'returns the list of widgets with their supported layouts and display settings' do
      is_expected.to have_http_status(:success)
      expect(JSON.parse(response.body)['widgets']).to eq(
        [
          {
            'endpoint' => 'my_widget',
            'name' => 'My Widget',
            'width' => 12,
            'icon' => 'line-chart',
            'layouts' => ['chart']
          }
        ]
      )
    end
  end

  describe '#show' do
    let(:endpoint) { 'my_widget' }
    let(:metadata) { { 'organization_ids' => ['org-fbba'] } }
    let(:params) { { 'endpoint' => endpoint, 'metadata' => metadata, 'layouts' => ['summary'], 'excluded' => 'param' } }
    let(:authorised_params) { params.except('excluded') }

    subject { get :show, params: params }

    it_behaves_like 'warden authenticated action'

    context 'when the request is authenticated' do
      before { login_as(double(:user)) }

      it 'instantiates a widget with the filtered params' do
        construction_params = authorised_params.deep_symbolize_keys
        expect(Widgets::MyWidget).to receive(:new).with(construction_params)
        subject
      end

      it_behaves_like 'success response', 'rendered widget!'

      context 'when the endpoint is not valid' do
        let(:endpoint) { 'anything' }
        it_behaves_like 'error response', 'Widget endpoint does not exist'
      end

      context 'when the widget has errors' do
        let(:errors) { double(:error, full_messages: ['Error for this widget']) }
        let(:invalid?) { true }
        it_behaves_like 'error response', 'Error for this widget'
      end

      # TODO: remove after refactor of authentication?
      context 'when no metadata is specified' do
        let(:metadata) { {} }
        it_behaves_like 'error response', 'No metadata specified', 'metadata' => nil
      end
    end
  end
end

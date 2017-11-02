# frozen_string_literal: true
# == Route Map
#
# Adding Warden to middleware
#               Prefix Verb URI Pattern                         Controller#Action
#                 ping GET  /ping(.:format)                     ping#index
#               api_v1 GET  /api/v1/widgets/:endpoint(.:format) api/v1/widgets#show
#       api_v1_widgets GET  /api/v1/widgets(.:format)           api/v1/widgets#index
#          api_v1_kpis GET  /api/v1/kpis(.:format)              api/v1/kpis#index
# api_v1_notifications POST /api/v1/notifications(.:format)     api/v1/notifications#create
#

# frozen_string_literal: true
Rails.application.routes.draw do
  get 'ping', to: 'ping#index'

  namespace :api do
    namespace :v1 do
      get 'widgets/:endpoint', to: 'widgets#show'
      resources :widgets, only: [:index]
      get 'kpis/*endpoint/:watchable', to: 'kpis#show'
      resources :kpis, only: [:index]
      resources :notifications, only: [:create]

      # ---------------- JSON API RESOURCES ------------------
      # jsonapi_resources :example, only: :index
    end
  end
end

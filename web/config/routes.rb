Rails.application.routes.draw do
  root 'api#index'
  resources :api, only: :index do
    post 'analyze', on: :collection
    post 'analyze_bytecode', on: :collection
  end
end
Rails.application.routes.draw do
  resources :purchases do
    member do
      get :payment
      post :check
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  telegram_webhook WebhookController

  root to: 'purchases#index'
end

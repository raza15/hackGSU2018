Rails.application.routes.draw do
  resources :sessions
  resources :orders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'sessions#new'

  get '/whichpayment', to: 'sessions#whichpayment'
  get '/creditpayment', to: 'sessions#creditpayment'
  get '/end_transaction', to: 'sessions#end_transaction'
  get '/magic', to: 'sessions#magic'
  get '/creditpayment_process', to: 'sessions#creditpayment_process'
  get '/maps_test', to: 'orders#maps_test'
  get '/maps_test_current_location', to: 'orders#maps_test_current_location'
  get '/inter_payment', to: 'sessions#inter_payment'
  get '/visa_checkout', to: 'sessions#visa_checkout'
  get '/nearby_business', to: 'sessions#nearby_business'
  # post '/carts' => 'orders#maps_test_post'

  resources :orders do
  	member do
  		patch 'maps_test_post'
  	end
  end
end

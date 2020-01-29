Rails.application.routes.draw do
  resources :users

  root 'users#index'

  get '/users' => 'users#index'

  post '/users' => 'users#create'

  post '/sign_in' => 'users#sign_in'

  post '/sign_out' => 'users#sign_out'

  put '/users' => 'users#update'
end

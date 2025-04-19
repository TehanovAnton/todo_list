Rails.application.routes.draw do
  devise_for :users

  resources :todos, only: [:index, :show, :create]
end

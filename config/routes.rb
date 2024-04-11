Rails.application.routes.draw do
  root 'posts#index'
  resources :posts do
    resources :favorites, only: %i(create destroy)
  end
  devise_for :accounts
  resources :accounts, only: [:show]
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end

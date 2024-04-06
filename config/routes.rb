Rails.application.routes.draw do
  root 'posts#index'
  devise_for :accounts
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end

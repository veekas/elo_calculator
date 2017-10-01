Rails.application.routes.draw do
  resources :players, only: [:index, :show, :create, :new] do
    scope module: :players do
      resources :clubs, only: [:index]
      resources :games, only: [:index]
      resources :ratings, only: [:index]
      resources :tournaments, only: [:index]
    end
  end
  resources :games, only: [:index, :new, :create, :show, :destroy]
  resources :matchups, only: [:new, :create, :show, :edit, :update, :destroy]
  resources :tournaments, only: [:index, :new, :update, :create, :show]
  get 'tournaments/:id/registration', to: 'tournaments#registration', as: :tournament_registration
  post 'tournaments/:id/close_registration', to: 'tournaments#close_registration', as: :close_registration
  resources :round_robins
  resources :single_eliminations
  resources :clubs, only: [:new, :create, :index] do
    scope module: :clubs do
      resources :memberships, only: [:new, :create]
    end
  end
  resources :clubs, only: :show, param: :slug
  resources :player_stats, only: [:show]

  root 'players#index'
end

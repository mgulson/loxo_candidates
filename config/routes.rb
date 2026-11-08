Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "users#index"
  get "users", to: "users#index", as: :users
  post "users/select", to: "users#select", as: :select_user

  resources :candidates, only: %i[index show new create], param: :name do
    post :assignments, on: :member, to: "candidate_assignments#create"
  end
  get "candidates/:candidate_name/scorecard/new", to: "scorecards#new", as: :new_candidate_scorecard
  post "candidates/:candidate_name/scorecard", to: "scorecards#create", as: :candidate_scorecard
end

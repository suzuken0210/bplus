Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API（バージョニング: /api/v1）
  namespace :api do
    namespace :v1 do
      resources :events, only: [ :index, :create, :show ] do
        # イベント参加（参加/キャンセル）。user_id はリクエストボディで受け取る。
        resource :participation, only: [ :create, :destroy ], controller: "participations"
      end
      # あるユーザーが参加中のイベント一覧。
      get "users/:user_id/participations", to: "participations#index"
      post "login", to: "sessions#create" # モックログイン
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

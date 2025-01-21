Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks, only: %i[index create destroy] do
        patch 'status_and_position', action: 'update_status_and_position', on: :member
      end
    end
  end
end

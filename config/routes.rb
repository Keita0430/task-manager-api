Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks, only: %i[index create] do
        patch 'status', action: 'update_status', on: :member
      end
    end
  end
end

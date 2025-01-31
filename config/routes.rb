Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks, only: %i[index create update destroy] do
        collection do
          post 'reorder'
        end

        resource :archive, only: [:update], controller: 'tasks/archives'
      end
    end
  end
end

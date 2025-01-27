Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks, only: %i[index create update destroy] do
        collection do
          post 'reorder'
        end
      end
    end
  end
end

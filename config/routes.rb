Rails.application.routes.draw do
  namespace :api, defualts:{ format: :json } do
    resources :survivor do
      member do
        put 'location'
      end
    end
  end
end

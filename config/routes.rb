Rails.application.routes.draw do
  namespace :api, defualts:{ format: :json } do
    
    resources :survivor do
      member do
        put 'location'
        put 'infected'
      end
      collection do
        post 'trade'
      end
    end
  end
end

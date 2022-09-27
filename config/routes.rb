Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api, defualts: { format: :json } do
    resources :survivor do
      member do
        put 'location'
        put 'infected'
      end
      collection do
        post 'trade'
      end
    end
    resources :reports do
      member do
        get  'pointsLostFromSurvivor'
      end
      collection do
        get 'infectedSurvivors'
        get 'uninfectedSurvivors'
        get 'averageResources'
      end
    end
  end
end

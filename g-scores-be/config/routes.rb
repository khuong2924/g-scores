Rails.application.routes.draw do
  namespace :api do
    get 'scores', to: 'scores#index'
    get 'reports/score_distribution', to: 'reports#score_distribution'
    get 'top_students/block_a', to: 'top_students#block_a'
    namespace :v1 do
      resources :students, only: [] do
        collection do
          get :search
          get :statistics
          get :top_students_group_a
          post :import_csv
        end
      end
    end
  end
end
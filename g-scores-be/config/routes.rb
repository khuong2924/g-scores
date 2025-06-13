Rails.application.routes.draw do
  namespace :api do
    get 'scores', to: 'scores#index'
    get 'reports/score_distribution', to: 'reports#score_distribution'
    get 'top_students/block_a', to: 'top_students#block_a'
  end
end
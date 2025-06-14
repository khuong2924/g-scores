require 'sidekiq/web'
require 'sidekiq/cron/web' if defined?(Sidekiq::Cron)

# Authentication for Sidekiq Web UI
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(username),
    ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'] || 'admin')
  ) &
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(password),
    ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'] || 'password')
  )
end

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'
  
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
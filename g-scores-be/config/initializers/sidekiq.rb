require 'sidekiq'
require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_URL'] || 'redis://localhost:6379/0'
  }

  # Configure error handling
  config.error_handlers << proc { |ex, ctx_hash| 
    Rails.logger.error "Sidekiq error: #{ex.message}"
    Rails.logger.error "Context: #{ctx_hash}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV['REDIS_URL'] || 'redis://localhost:6379/0'
  }
end 
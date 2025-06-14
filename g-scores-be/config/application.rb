require_relative "boot"
require 'logger'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GScoresBe
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure file upload size limit
    config.action_dispatch.http_content_length_limit = 100.megabytes

    # Configure CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost', 'http://localhost:8080'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true,
          expose: ['Authorization', 'Content-Type', 'Accept', 'Access-Control-Allow-Origin']
      end
    end
  end
end

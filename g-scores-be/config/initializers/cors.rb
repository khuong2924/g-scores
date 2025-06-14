Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGINS', '').split(',')

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'Content-Type', 'Accept', 'Access-Control-Allow-Origin'],
      credentials: true,
      max_age: 86400,
      supports_credentials: true
  end
end 
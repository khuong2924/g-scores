Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost', 'http://localhost:80', 'http://localhost:3000',
            'https://localhost', 'https://localhost:80', 'https://localhost:3000'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      max_age: 0,
      credentials: true
  end
end 
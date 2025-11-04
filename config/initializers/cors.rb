# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Get origins from environment variable or use defaults
    # In production, set CORS_ORIGINS to your frontend URL
    default_origins = if Rails.env.production?
      '*'  # Allow all origins in production, or set specific domains via CORS_ORIGINS
    else
      'localhost:3000,localhost:3001,127.0.0.1:3000'
    end
    
    origins_list = ENV.fetch('CORS_ORIGINS', default_origins)
    origins origins_list == '*' ? '*' : origins_list.split(',')

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization', 'Idempotency-Key']
  end
end

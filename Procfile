# Procfile

# 1️⃣ Web process: serves traffic
web: bundle exec puma -C config/puma.rb

# 2️⃣ Worker process: background jobs
worker: bundle exec sidekiq -C config/sidekiq.yml

# 3️⃣ Release phase: database setup and swagger generation
release: bundle exec rails db:prepare RAILS_ENV=production && bundle exec rake rswag:specs:swaggerize RAILS_ENV=production || true

# Procfile

# 1️⃣ Web process: serves traffic
web: bundle exec puma -C config/puma.rb

# 2️⃣ Worker process: background jobs
worker: bundle exec sidekiq -C config/sidekiq.yml

# 3️⃣ Release phase: database setup
release: bundle exec rails db:prepare RAILS_ENV=production

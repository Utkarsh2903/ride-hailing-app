# Procfile

# 1️⃣ Web process: serves traffic
web: bundle exec puma -C config/puma.rb

# 2️⃣ Worker process: background jobs
worker: bundle exec sidekiq -C config/sidekiq.yml

# 3️⃣ Release phase: database setup & extensions
release: |
  echo "🔧 Preparing production database..."
  bundle exec rails db:prepare RAILS_ENV=production

  echo "🧩 Creating PostGIS and UUID extensions..."
  bundle exec rails runner "begin; ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis'); ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"'); rescue => e; puts e.message; end" RAILS_ENV=production

  echo "✅ Database ready!"

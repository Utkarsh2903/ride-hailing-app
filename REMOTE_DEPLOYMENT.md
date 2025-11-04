# 🚀 Remote Deployment Guide

Skip local setup and deploy directly to the cloud for testing!

---

## 🎯 Best Options for Quick Deployment

| Platform | PostgreSQL+PostGIS | Redis | Sidekiq | Free Tier | Setup Time |
|----------|-------------------|-------|---------|-----------|------------|
| **Railway** | ✅ | ✅ | ✅ | $5 credit | 10 min |
| **Render** | ✅ | ✅ | ✅ | Free | 15 min |
| **Heroku** | ✅ | ✅ | ✅ | Limited | 15 min |
| **Fly.io** | ✅ | ✅ | ✅ | Free | 20 min |

**Recommended: Railway or Render** (easiest setup)

---

## 🚂 Option 1: Railway (Recommended - Fastest)

Railway is the fastest way to deploy Rails apps with all dependencies.

### Step 1: Prerequisites

1. Create account: https://railway.app
2. Install Railway CLI:
   ```bash
   brew install railway
   ```

3. Login:
   ```bash
   railway login
   ```

### Step 2: Initialize Project

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# Initialize Railway project
railway init

# Link to your project
railway link
```

### Step 3: Add Services

```bash
# Add PostgreSQL with PostGIS
railway add --database postgres

# Add Redis
railway add --database redis

# This creates two services in your Railway project
```

### Step 4: Configure Environment Variables

```bash
# Set Rails master key
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)

# Set production environment
railway variables set RAILS_ENV=production
railway variables set RACK_ENV=production

# Set secret key base
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)
```

### Step 5: Update Database Configuration

Update `config/database.yml`:

```yaml
production:
  <<: *default
  adapter: postgis
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### Step 6: Create Procfile

Create `Procfile` in your project root:

```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate
```

### Step 7: Enable PostGIS

Create `db/setup_postgis.sql`:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

Update your first migration to enable PostGIS if not already done.

### Step 8: Deploy

```bash
# Commit your changes
git add .
git commit -m "Prepare for Railway deployment"

# Deploy
railway up

# Run migrations
railway run rails db:migrate

# Seed database (optional)
railway run rails db:seed
```

### Step 9: Access Your App

```bash
# Get your app URL
railway open

# View logs
railway logs
```

**Your app is now live!** 🎉

---

## 🎨 Option 2: Render (Most Generous Free Tier)

Render offers a generous free tier perfect for testing.

### Step 1: Prerequisites

1. Create account: https://render.com
2. Create a GitHub account if you don't have one
3. Push your code to GitHub

### Step 2: Push to GitHub

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit"

# Create a repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/ride-hailing-app.git
git branch -M main
git push -u origin main
```

### Step 3: Create Blueprint File

Create `render.yaml` in your project root:

```yaml
databases:
  - name: ride-hailing-db
    databaseName: ride_hailing_production
    user: ride_hailing
    plan: free
    postgresMajorVersion: 16
    
  - name: ride-hailing-redis
    plan: free

services:
  - type: web
    name: ride-hailing-web
    env: ruby
    plan: free
    buildCommand: bundle install && bundle exec rails assets:precompile db:migrate
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: ride-hailing-db
          property: connectionString
      - key: REDIS_URL
        fromDatabase:
          name: ride-hailing-redis
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
      - key: RACK_ENV
        value: production
      - key: SECRET_KEY_BASE
        generateValue: true

  - type: worker
    name: ride-hailing-worker
    env: ruby
    plan: free
    buildCommand: bundle install
    startCommand: bundle exec sidekiq -C config/sidekiq.yml
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: ride-hailing-db
          property: connectionString
      - key: REDIS_URL
        fromDatabase:
          name: ride-hailing-redis
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
```

### Step 4: Deploy on Render

1. Go to https://dashboard.render.com
2. Click "New" → "Blueprint"
3. Connect your GitHub repository
4. Render will detect `render.yaml` and set up everything
5. Add your `RAILS_MASTER_KEY` as an environment variable
6. Click "Apply"

### Step 5: Enable PostGIS

After deployment, run in Render Shell:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

**Your app is now live!** 🎉

---

## 🟣 Option 3: Heroku (Classic Choice)

### Step 1: Prerequisites

```bash
# Install Heroku CLI
brew tap heroku/brew && brew install heroku

# Login
heroku login
```

### Step 2: Create Heroku App

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# Create app
heroku create ride-hailing-app-yourname

# Add PostgreSQL with PostGIS
heroku addons:create heroku-postgresql:essential-0

# Add Redis
heroku addons:create heroku-redis:mini

# Add Sidekiq (optional, costs money)
# Or use free worker dyno
```

### Step 3: Enable PostGIS

```bash
# Access database
heroku pg:psql

# Inside psql
CREATE EXTENSION IF NOT EXISTS postgis;
\q
```

### Step 4: Configure Environment

```bash
# Set Rails master key
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Set secret key
heroku config:set SECRET_KEY_BASE=$(openssl rand -hex 64)
```

### Step 5: Create Procfile

Create `Procfile`:

```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate
```

### Step 6: Deploy

```bash
git add .
git commit -m "Configure for Heroku"
git push heroku main

# Scale worker (if you want Sidekiq)
heroku ps:scale worker=1

# Run seeds
heroku run rails db:seed

# View logs
heroku logs --tail
```

**Your app is now live!** 🎉

---

## 🪂 Option 4: Fly.io (Global CDN)

### Step 1: Install Fly CLI

```bash
brew install flyctl

# Sign up/login
fly auth signup
# or
fly auth login
```

### Step 2: Launch App

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# Launch (this creates fly.toml)
fly launch

# When prompted:
# - Choose app name
# - Select region
# - Choose YES for PostgreSQL
# - Choose YES for Redis
```

### Step 3: Configure PostGIS

```bash
# Connect to database
fly postgres connect -a your-db-name

# Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
\q
```

### Step 4: Set Secrets

```bash
# Set Rails master key
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# Set secret key base
fly secrets set SECRET_KEY_BASE=$(openssl rand -hex 64)
```

### Step 5: Deploy

```bash
fly deploy

# View logs
fly logs

# Open app
fly open
```

**Your app is now live!** 🎉

---

## 📋 Pre-Deployment Checklist

Before deploying, make sure:

- [ ] `config/master.key` exists
- [ ] `Gemfile.lock` is committed
- [ ] All migrations are committed
- [ ] Production database config uses `ENV['DATABASE_URL']`
- [ ] `config/environments/production.rb` is configured
- [ ] Assets are precompiled (`rails assets:precompile`)

### Update Production Config

Edit `config/environments/production.rb`:

```ruby
# Around line 20-25
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

# Around line 60-65
config.active_storage.service = :local  # or :amazon if using S3

# Around line 90-95
config.force_ssl = false  # Set to true if you have SSL

# At the end
config.log_level = :info
```

### Update Database Config

Edit `config/database.yml`:

```yaml
production:
  <<: *default
  adapter: postgis
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  # These are important for PostGIS
  schema_search_path: "public,postgis"
```

---

## 🧪 Testing Your Deployed App

### 1. Health Check

```bash
curl https://your-app.railway.app/up
# or
curl https://your-app.onrender.com/up
```

### 2. Register a User

```bash
curl -X POST https://your-app.railway.app/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone_number": "+12025551234",
    "first_name": "Test",
    "last_name": "User",
    "role": "rider"
  }'
```

### 3. Login

```bash
curl -X POST https://your-app.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 4. Create a Ride

```bash
curl -X POST https://your-app.railway.app/api/v1/rides \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickup_latitude": 37.7749,
    "pickup_longitude": -122.4194,
    "pickup_address": "San Francisco",
    "dropoff_latitude": 37.8044,
    "dropoff_longitude": -122.2712,
    "dropoff_address": "Oakland",
    "tier": "standard"
  }'
```

---

## 🐛 Common Deployment Issues

### Issue 1: PostGIS Not Available

**Solution:**
```bash
# Railway
railway run rails db:setup_postgis

# Heroku
heroku pg:psql
CREATE EXTENSION postgis;

# Render
# Use Render Shell from dashboard
CREATE EXTENSION postgis;
```

### Issue 2: Assets Not Loading

**Solution:**
Update `config/environments/production.rb`:
```ruby
config.public_file_server.enabled = true
config.assets.compile = true
```

### Issue 3: Database Connection Error

**Solution:**
Check your `DATABASE_URL` is set:
```bash
# Railway
railway variables

# Heroku
heroku config

# Render
# Check in Render dashboard
```

### Issue 4: Sidekiq Not Running

**Solution:**
Make sure you have a worker process:
```bash
# Railway - add in railway.toml
[deploy]
startCommand = "bundle exec sidekiq"

# Heroku
heroku ps:scale worker=1

# Render - check render.yaml has worker service
```

---

## 💰 Cost Comparison

| Platform | Free Tier | Paid (Basic) | Best For |
|----------|-----------|--------------|----------|
| **Railway** | $5 credit/month | $5/month | Quick testing |
| **Render** | Free (with limits) | $7/month | Long-term testing |
| **Heroku** | Limited free | $7/month | Production-ready |
| **Fly.io** | Free (generous) | $3/month | Global deployment |

---

## 🎯 Recommended Path

For testing your ride-hailing app, I recommend:

1. **Railway** - Fastest setup (10 minutes)
   - Use the $5 free credit
   - Perfect for quick testing
   - Easy CLI

2. **Render** - If you need more time
   - Generous free tier
   - Good for extended testing
   - Web-based setup

---

## 📝 Quick Deploy Commands

### Railway (Fastest)
```bash
brew install railway
railway login
railway init
railway add --database postgres
railway add --database redis
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)
git add . && git commit -m "Deploy"
railway up
railway run rails db:migrate db:seed
```

### Render (Free)
```bash
# Just push to GitHub
git push origin main

# Then deploy via Render dashboard
# https://dashboard.render.com
```

---

## 🆘 Need Help?

**Railway:** https://railway.app/help
**Render:** https://render.com/docs
**Heroku:** https://help.heroku.com
**Fly.io:** https://fly.io/docs

---

## ✅ Post-Deployment

Once deployed, you can:
- ✅ Test all API endpoints
- ✅ Share the URL with your team
- ✅ Test on mobile devices
- ✅ Run load tests
- ✅ Integrate with frontend

**Your app is accessible from anywhere!** 🌍

---

**Next:** Test your APIs using the deployed URL instead of localhost:3000!


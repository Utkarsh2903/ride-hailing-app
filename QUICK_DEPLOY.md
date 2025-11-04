# ⚡ Quick Deploy Guide

Deploy in 5 minutes! Choose your platform:

---

## 🚂 Railway (Fastest - 5 minutes)

```bash
# 1. Install Railway CLI
brew install railway

# 2. Login
railway login

# 3. Navigate to your project
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# 4. Initialize project
railway init

# 5. Add PostgreSQL and Redis
railway add --database postgres
railway add --database redis

# 6. Set environment variables
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)
railway variables set RAILS_ENV=production
railway variables set RACK_ENV=production

# 7. Commit and deploy
git add .
git commit -m "Deploy to Railway"
railway up

# 8. Run migrations
railway run rails db:migrate

# 9. Enable PostGIS
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"

# 10. Seed database (optional)
railway run rails db:seed

# 11. Open your app
railway open
```

**Done!** Your app is live at: `https://your-app.railway.app` 🎉

---

## 🎨 Render (Free - 10 minutes)

### Option A: Via GitHub (Recommended)

```bash
# 1. Create GitHub repo and push
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/ride-hailing-app.git
git push -u origin main

# 2. Go to Render Dashboard
open https://dashboard.render.com

# 3. Click "New" → "Blueprint"
# 4. Connect your GitHub repo
# 5. Render will detect render.yaml
# 6. Add RAILS_MASTER_KEY in environment variables
# 7. Click "Apply"

# 8. Once deployed, enable PostGIS via Render Shell:
CREATE EXTENSION IF NOT EXISTS postgis;
```

### Option B: Via Render CLI

```bash
# 1. Install Render CLI
brew install render

# 2. Login
render login

# 3. Deploy
render deploy
```

**Done!** Your app is live at: `https://your-app.onrender.com` 🎉

---

## 🟣 Heroku (Classic - 10 minutes)

```bash
# 1. Install Heroku CLI
brew tap heroku/brew && brew install heroku

# 2. Login
heroku login

# 3. Navigate to project
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# 4. Create app
heroku create ride-hailing-$(date +%s)

# 5. Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# 6. Add Redis
heroku addons:create heroku-redis:mini

# 7. Enable PostGIS
heroku pg:psql
CREATE EXTENSION IF NOT EXISTS postgis;
\q

# 8. Set environment variables
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# 9. Deploy
git add .
git commit -m "Deploy to Heroku"
git push heroku main

# 10. Scale worker (for Sidekiq)
heroku ps:scale worker=1

# 11. Run seeds
heroku run rails db:seed

# 12. Open app
heroku open
```

**Done!** Your app is live at: `https://your-app.herokuapp.com` 🎉

---

## 🧪 Test Your Deployed App

Once deployed, test with:

```bash
# Replace YOUR_APP_URL with your actual URL
export APP_URL="https://your-app.railway.app"

# 1. Health check
curl $APP_URL/up

# 2. Register user
curl -X POST $APP_URL/api/v1/auth/register \
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

# 3. Login
curl -X POST $APP_URL/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Copy the JWT token, then:

# 4. Create a ride
curl -X POST $APP_URL/api/v1/rides \
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

## 🐛 Troubleshooting

### Problem: Deployment fails

**Solution:**
```bash
# Check logs
railway logs        # Railway
render logs         # Render  
heroku logs --tail  # Heroku
```

### Problem: Database connection error

**Solution:**
```bash
# Verify DATABASE_URL is set
railway variables   # Railway
heroku config       # Heroku
# For Render: check dashboard
```

### Problem: PostGIS not working

**Solution:**
```bash
# Enable PostGIS extension
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION postgis')"

# Or via psql
railway run psql
CREATE EXTENSION postgis;
```

---

## ✅ Deployment Checklist

Before deploying:
- [x] `Procfile` created ✅
- [x] `render.yaml` created (for Render) ✅
- [x] `config/database.yml` uses `DATABASE_URL` ✅
- [x] `config/environments/production.rb` configured ✅
- [x] `config/master.key` exists
- [ ] All code committed to git
- [ ] Ready to deploy!

---

## 🎯 Recommended: Railway

For the fastest deployment with least hassle:

```bash
brew install railway
railway login
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"
railway init
railway add --database postgres
railway add --database redis
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)
git add . && git commit -m "Deploy"
railway up
railway run rails db:migrate
railway open
```

**Time: 5 minutes | Cost: $5/month credit** 🚀

---

## 📱 Share Your App

Once deployed, share the URL:
- https://your-app.railway.app
- https://your-app.onrender.com
- https://your-app.herokuapp.com

Your team/client can now test from anywhere! 🌍


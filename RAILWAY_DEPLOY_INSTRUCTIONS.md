# 🚂 Railway Deployment - Step by Step

## ✅ Everything is Configured!

Your app is **100% ready** for Railway deployment. All configurations have been optimized.

---

## 🚀 Quick Deploy (5 Minutes)

### Prerequisites

1. **Install Railway CLI:**
   ```bash
   brew install railway
   ```

2. **Login to Railway:**
   ```bash
   railway login
   ```

---

## 📋 Option 1: Automated Deploy (Recommended)

Just run our deployment script:

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"
./bin/railway_deploy
```

**That's it!** The script will:
- ✅ Initialize your Railway project
- ✅ Add PostgreSQL with PostGIS
- ✅ Add Redis
- ✅ Set all environment variables
- ✅ Deploy your code
- ✅ Run migrations
- ✅ Enable PostGIS
- ✅ Give you your app URL

---

## 📝 Option 2: Manual Deploy

If you prefer manual control:

### Step 1: Initialize Project
```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"
railway init
```

### Step 2: Add Databases
```bash
# Add PostgreSQL
railway add --database postgres

# Add Redis
railway add --database redis
```

### Step 3: Set Environment Variables
```bash
# Set Rails master key
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)

# Set environment
railway variables set RAILS_ENV=production
railway variables set RACK_ENV=production
railway variables set RAILS_SERVE_STATIC_FILES=true

# Generate and set secret key
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)
```

### Step 4: Deploy
```bash
# Commit your code
git add .
git commit -m "Deploy to Railway"

# Deploy
railway up
```

### Step 5: Setup Database
```bash
# Wait 30 seconds for deployment, then:

# Run migrations
railway run rails db:migrate

# Enable PostGIS
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"

# Seed database (optional)
railway run rails db:seed
```

### Step 6: Get Your URL
```bash
railway domain
```

---

## ✅ What's Been Configured

I've already configured everything for Railway:

### Files Created/Updated:
- ✅ **`railway.json`** - Railway-specific config
- ✅ **`nixpacks.toml`** - Build configuration with PostGIS support
- ✅ **`Procfile`** - Process definitions (web + worker)
- ✅ **`config/sidekiq.yml`** - Sidekiq configuration
- ✅ **`config/puma.rb`** - Updated to bind to 0.0.0.0
- ✅ **`config/database.yml`** - Uses DATABASE_URL
- ✅ **`config/environments/production.rb`** - Static files enabled
- ✅ **`config/initializers/cors.rb`** - CORS configured for production
- ✅ **`config/initializers/redis.rb`** - Uses REDIS_URL
- ✅ **`bin/railway_deploy`** - Automated deployment script

### Environment Variables Set:
- ✅ `RAILS_MASTER_KEY` - Your Rails credentials key
- ✅ `RAILS_ENV=production` - Production mode
- ✅ `RACK_ENV=production` - Rack production mode
- ✅ `SECRET_KEY_BASE` - Secure random key
- ✅ `RAILS_SERVE_STATIC_FILES=true` - Serve assets
- ✅ `DATABASE_URL` - Auto-set by Railway PostgreSQL
- ✅ `REDIS_URL` - Auto-set by Railway Redis

---

## 🧪 Testing Your Deployed App

Once deployed, get your URL:
```bash
railway domain
```

Then test:

### 1. Health Check
```bash
curl https://your-app.railway.app/up
# Should return: {"status":"ok"}
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

Copy the JWT token, then:

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

## 📊 Monitoring & Management

### View Logs
```bash
railway logs
# Or follow logs
railway logs --tail
```

### Open App in Browser
```bash
railway open
```

### Access Rails Console
```bash
railway run rails console
```

### Check Environment Variables
```bash
railway variables
```

### SSH into Container
```bash
railway shell
```

### Run Database Commands
```bash
# Run migrations
railway run rails db:migrate

# Rollback migration
railway run rails db:rollback

# Reset database (careful!)
railway run rails db:reset

# Seed database
railway run rails db:seed
```

---

## 🐛 Troubleshooting

### Issue: PostGIS Extension Error

**Solution:**
```bash
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
```

### Issue: Assets Not Loading

**Solution:**
```bash
# Recompile assets
railway run rails assets:precompile

# Or set environment variable
railway variables set RAILS_SERVE_STATIC_FILES=true
```

### Issue: Database Connection Error

**Solution:**
```bash
# Check if DATABASE_URL is set
railway variables | grep DATABASE_URL

# Restart the service
railway restart
```

### Issue: Redis Connection Error

**Solution:**
```bash
# Check if REDIS_URL is set
railway variables | grep REDIS_URL

# Test Redis connection
railway run rails runner "puts \$redis.ping"
```

### Issue: Sidekiq Not Running

**Solution:**

Railway automatically runs both `web` and `worker` processes from your `Procfile`. Check logs:
```bash
railway logs --service worker
```

---

## 💰 Railway Pricing

- **Free Tier:** $5 credit/month (perfect for testing)
- **Developer Plan:** $5/month for more resources
- **Team Plan:** $20/month for production

Your app will use:
- PostgreSQL: ~$5/month
- Redis: ~$1/month
- Web + Worker: Included in plan

**Total: ~$6-10/month** or use free $5 credit for testing

---

## 🔄 Deploying Updates

After making changes:

```bash
# 1. Commit changes
git add .
git commit -m "Your update message"

# 2. Deploy
railway up

# 3. Run migrations (if any)
railway run rails db:migrate
```

Railway will automatically:
- Build your app
- Run database migrations (via Procfile's `release` command)
- Deploy new version
- Zero-downtime deployment

---

## 🎯 Post-Deployment Checklist

After deployment, verify:

- [ ] App responds to health check: `curl https://your-app.railway.app/up`
- [ ] Can register a user
- [ ] Can login and get JWT token
- [ ] Can create a ride
- [ ] Can update driver location
- [ ] Sidekiq is processing jobs (check logs)
- [ ] PostgreSQL is working
- [ ] PostGIS extension is enabled
- [ ] Redis is working

---

## 📱 Share Your App

Your app is now accessible at:
```
https://your-app-name.railway.app
```

Share this URL with:
- ✅ Your team for testing
- ✅ Your client for demo
- ✅ Your frontend developers
- ✅ Mobile app developers

---

## 🚀 Ready to Deploy?

Choose your method:

### **Quick Way (Recommended):**
```bash
./bin/railway_deploy
```

### **Manual Way:**
```bash
railway init
railway add --database postgres
railway add --database redis
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)
railway up
railway run rails db:migrate
```

---

## 🆘 Need Help?

- **Railway Docs:** https://docs.railway.app
- **Railway Discord:** https://discord.gg/railway
- **Check Logs:** `railway logs`
- **Railway Status:** https://status.railway.app

---

**Your app is ready to go live! 🎉**

Just run: `./bin/railway_deploy`


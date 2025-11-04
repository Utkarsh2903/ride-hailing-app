# ✅ Railway Deployment Checklist

## Pre-Deployment Verification

### ✅ All Configurations Done

| Item | Status | Notes |
|------|--------|-------|
| **Railway Config** | ✅ | `railway.json` created |
| **Build Config** | ✅ | `nixpacks.toml` with PostGIS support |
| **Procfile** | ✅ | Web + Worker + Release defined |
| **Puma Config** | ✅ | Binds to 0.0.0.0:$PORT |
| **Database Config** | ✅ | Uses DATABASE_URL |
| **Redis Config** | ✅ | Uses REDIS_URL |
| **Sidekiq Config** | ✅ | config/sidekiq.yml created |
| **CORS Config** | ✅ | Allows all origins in production |
| **Static Files** | ✅ | Enabled for Railway |
| **PostGIS Migration** | ✅ | enable_extension in first migration |
| **Deployment Script** | ✅ | bin/railway_deploy ready |

---

## Files Ready for Deployment

### Created Files ✅
- ✅ `railway.json` - Railway configuration
- ✅ `nixpacks.toml` - Build with PostGIS dependencies
- ✅ `Procfile` - Process definitions
- ✅ `config/sidekiq.yml` - Sidekiq queues config
- ✅ `bin/railway_deploy` - Automated deployment script
- ✅ `RAILWAY_DEPLOY_INSTRUCTIONS.md` - Complete guide

### Updated Files ✅
- ✅ `config/puma.rb` - Binds to 0.0.0.0
- ✅ `config/database.yml` - Uses DATABASE_URL for production
- ✅ `config/environments/production.rb` - Static files enabled
- ✅ `config/initializers/cors.rb` - Production-ready CORS

### Existing Files (Already Good) ✅
- ✅ `config/initializers/redis.rb` - Uses REDIS_URL
- ✅ `config/initializers/sidekiq.rb` - Redis configured
- ✅ `db/migrate/*_enable_postgis_extension.rb` - PostGIS enabled
- ✅ `config/master.key` - Should exist

---

## Quick Deployment Commands

### Option 1: Automated (Recommended)
```bash
./bin/railway_deploy
```

### Option 2: Manual
```bash
railway init
railway add --database postgres
railway add --database redis
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)
git add . && git commit -m "Deploy"
railway up
railway run rails db:migrate
```

---

## Environment Variables Required

These will be automatically set by the deployment script:

- ✅ `RAILS_MASTER_KEY` - From your config/master.key
- ✅ `RAILS_ENV=production`
- ✅ `RACK_ENV=production`
- ✅ `SECRET_KEY_BASE` - Auto-generated
- ✅ `RAILS_SERVE_STATIC_FILES=true`
- ✅ `DATABASE_URL` - Auto-set by Railway
- ✅ `REDIS_URL` - Auto-set by Railway

---

## Services Included

Your deployment will have:

### 1. Web Service (Puma)
- **Process:** `bundle exec puma -C config/puma.rb`
- **Port:** Dynamic (Railway assigns)
- **Threads:** 5 (configurable via RAILS_MAX_THREADS)

### 2. Worker Service (Sidekiq)
- **Process:** `bundle exec sidekiq -C config/sidekiq.yml`
- **Concurrency:** 10 in production
- **Queues:** critical, high, default, low

### 3. PostgreSQL Database
- **Version:** 16
- **Extensions:** postgis, uuid-ossp
- **Connection:** Via DATABASE_URL

### 4. Redis Cache
- **Connection:** Via REDIS_URL
- **Used for:** Cache, Sidekiq, Real-time features

---

## Post-Deployment Steps

After deployment:

1. **Verify Health:**
   ```bash
   curl https://your-app.railway.app/up
   ```

2. **Check Logs:**
   ```bash
   railway logs
   ```

3. **Test API:**
   ```bash
   curl https://your-app.railway.app/api/v1/auth/register \
     -H "Content-Type: application/json" \
     -d '{...}'
   ```

4. **Monitor Services:**
   - Check Railway dashboard for metrics
   - View logs for any errors
   - Test all core endpoints

---

## Potential Issues & Solutions

### Issue: "Master key not found"
**Solution:**
```bash
# Make sure config/master.key exists
ls -la config/master.key

# If missing, generate it
EDITOR='echo' rails credentials:edit
```

### Issue: "PostGIS extension not available"
**Solution:**
```bash
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
```

### Issue: "Cannot connect to database"
**Solution:**
```bash
# Check DATABASE_URL
railway variables | grep DATABASE_URL

# Restart
railway restart
```

### Issue: "Redis connection failed"
**Solution:**
```bash
# Check REDIS_URL
railway variables | grep REDIS_URL

# Test connection
railway run rails runner "puts \$redis.ping"
```

---

## Estimated Deployment Time

- **Initial Setup:** 2-3 minutes
- **Build Time:** 3-5 minutes
- **Total:** ~10 minutes first time
- **Subsequent Deploys:** ~3-5 minutes

---

## Cost Estimate

### Free Tier ($5 credit/month)
- PostgreSQL: ~$5/month
- Redis: ~$1/month
- Compute: Included
- **Total:** Can run on free credit for testing

### Paid (if exceeds free tier)
- **Basic:** ~$6-10/month total
- **Production:** ~$20-30/month with more resources

---

## Features Enabled

Your deployed app will have:
- ✅ Multi-tenant support
- ✅ Real-time driver location updates
- ✅ Driver-rider matching
- ✅ Trip lifecycle management
- ✅ Payment processing (mock)
- ✅ Notifications
- ✅ Background job processing
- ✅ Geospatial queries (PostGIS)
- ✅ Caching (Redis)
- ✅ API rate limiting
- ✅ JWT authentication
- ✅ CORS enabled

---

## Testing Your Deployment

Use this test script after deployment:

```bash
#!/bin/bash
APP_URL="https://your-app.railway.app"

# 1. Health check
echo "Testing health endpoint..."
curl -s $APP_URL/up | grep -q "ok" && echo "✅ Health check passed" || echo "❌ Health check failed"

# 2. Register user
echo "Testing user registration..."
REGISTER_RESPONSE=$(curl -s -X POST $APP_URL/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone_number": "+12025551234",
    "first_name": "Test",
    "last_name": "User",
    "role": "rider"
  }')

echo $REGISTER_RESPONSE | grep -q "email" && echo "✅ Registration passed" || echo "❌ Registration failed"

# 3. Login
echo "Testing login..."
LOGIN_RESPONSE=$(curl -s -X POST $APP_URL/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo $TOKEN | grep -q "eyJ" && echo "✅ Login passed" || echo "❌ Login failed"

echo ""
echo "JWT Token: $TOKEN"
echo ""
echo "All tests completed!"
```

---

## Ready to Deploy? 🚀

Run this command:

```bash
./bin/railway_deploy
```

Or follow the manual steps in `RAILWAY_DEPLOY_INSTRUCTIONS.md`

---

**Everything is configured and ready!** ✅


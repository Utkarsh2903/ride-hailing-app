# 🚂 Railway Manual Deployment - Complete Step-by-Step Guide

Follow these exact steps to deploy your Ride Hailing App to Railway.

---

## 📋 Prerequisites

Before starting, you need:
- ✅ Railway account (free): https://railway.app
- ✅ Your code in a Git repository (GitHub recommended)
- ✅ `config/master.key` file in your project

**Time Required:** 10-15 minutes

---

## Part 1: Prepare Your Code (5 minutes)

### Step 1.1: Initialize Git (if not already done)

```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Prepare for Railway deployment"
```

### Step 1.2: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `ride-hailing-app` (or any name)
3. Set to **Private** (recommended) or Public
4. Click "**Create repository**"

### Step 1.3: Push to GitHub

```bash
# Add GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/ride-hailing-app.git

# Push code
git branch -M main
git push -u origin main
```

**✅ Checkpoint:** Your code should now be on GitHub.

---

## Part 2: Create Railway Project (10 minutes)

### Step 2.1: Sign Up / Login to Railway

1. Go to: **https://railway.app**
2. Click "**Login**" or "**Start a New Project**"
3. Sign in with **GitHub** (recommended)
4. Authorize Railway to access your repositories

**✅ Checkpoint:** You should see Railway dashboard.

---

### Step 2.2: Create New Project

1. Click "**New Project**" button (big purple button)
2. You'll see several options:
   - Deploy from GitHub repo
   - Deploy from template
   - Empty project
   - Provision PostgreSQL/Redis/etc.

3. Click "**Deploy from GitHub repo**"

4. A list of your GitHub repositories will appear
5. Find and click "**ride-hailing-app**" (or your repo name)

6. Railway will automatically:
   - Detect it's a Rails app
   - Start deploying
   - Assign a URL

**Wait 2-3 minutes for initial build...**

**✅ Checkpoint:** You should see a deployment in progress.

---

### Step 2.3: Add PostgreSQL Database

1. In your project dashboard, click "**+ New**" button (top right)
2. Select "**Database**"
3. Click "**Add PostgreSQL**"
4. Railway will create a PostgreSQL database
5. Wait ~30 seconds for provisioning

**You'll see:**
- PostgreSQL service added to your project
- Automatically gets `DATABASE_URL` environment variable

**✅ Checkpoint:** PostgreSQL service visible in your project.

---

### Step 2.4: Add Redis Database

1. Click "**+ New**" button again
2. Select "**Database**"
3. Click "**Add Redis**"
4. Railway will create a Redis instance
5. Wait ~30 seconds

**You'll see:**
- Redis service added to your project
- Automatically gets `REDIS_URL` environment variable

**✅ Checkpoint:** You now have 3 services: App, PostgreSQL, Redis.

---

### Step 2.5: Configure Environment Variables

1. Click on your **App service** (the one with your repo name)
2. Go to "**Variables**" tab
3. Click "**+ Add Variable**" or "**Raw Editor**"

**Add these variables one by one:**

#### Variable 1: RAILS_MASTER_KEY
```
RAILS_MASTER_KEY=<paste content from config/master.key>
```

**How to get it:**
```bash
cat config/master.key
# Copy the output
```

#### Variable 2: RAILS_ENV
```
RAILS_ENV=production
```

#### Variable 3: RACK_ENV
```
RACK_ENV=production
```

#### Variable 4: RAILS_SERVE_STATIC_FILES
```
RAILS_SERVE_STATIC_FILES=true
```

#### Variable 5: SECRET_KEY_BASE (Generate)
```bash
# Generate a secret
openssl rand -hex 64
# Copy the output
```
Then add:
```
SECRET_KEY_BASE=<paste generated secret>
```

**✅ Checkpoint:** You should have 5 custom variables + DATABASE_URL + REDIS_URL.

---

### Step 2.6: Redeploy with Variables

1. After adding all variables, Railway will automatically redeploy
2. Or click "**Deploy**" button to trigger manual deployment
3. Wait 3-5 minutes for build and deployment

**Monitor the logs:**
- Click on your app service
- Go to "**Deployments**" tab
- Click on the latest deployment
- View "**Build Logs**" and "**Deploy Logs**"

**✅ Checkpoint:** Deployment shows "Active" status.

---

### Step 2.7: Run Database Migrations

1. Click on your **App service**
2. Look for "**Settings**" tab or three-dot menu
3. Find and click "**Run a command**" or open the shell

**Or use Railway CLI:**
```bash
# Install Railway CLI
brew install railway

# Login
railway login

# Link to your project
railway link

# Run migrations
railway run rails db:migrate
```

**Without CLI (using dashboard):**
1. Go to app service → Settings
2. Under "Deploy" section, find "Custom Start Command"
3. Or use the Railway CLI as shown above

**✅ Checkpoint:** Migrations completed successfully.

---

### Step 2.8: Enable PostGIS Extension

**Using Railway CLI:**
```bash
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
```

**Or connect to PostgreSQL directly:**
1. Click on **PostgreSQL service**
2. Go to "**Data**" tab
3. Click "**Connect**" → Opens PostgreSQL connection details
4. Use the provided connection string with psql:

```bash
psql <CONNECTION_STRING>
# Then in psql:
CREATE EXTENSION IF NOT EXISTS postgis;
\q
```

**✅ Checkpoint:** PostGIS extension enabled.

---

### Step 2.9: Seed Database (Optional)

If you want test data:

```bash
railway run rails db:seed
```

Or create a seed file first if you haven't:

```ruby
# db/seeds.rb
tenant = Tenant.create!(
  slug: 'demo',
  name: 'Demo Ride Co',
  subdomain: 'demo',
  status: 'active',
  region: 'us-east-1'
)

puts "✅ Tenant created: #{tenant.name}"

# Add more seed data as needed
```

Then run:
```bash
railway run rails db:seed
```

**✅ Checkpoint:** Database seeded with initial data.

---

### Step 2.10: Configure Custom Domain (Optional)

1. Click on your **App service**
2. Go to "**Settings**" tab
3. Scroll to "**Networking**" section
4. You'll see your Railway domain: `your-app.railway.app`

**To add custom domain:**
1. Click "**Generate Domain**" if not already generated
2. Click "**+ Add Domain**"
3. Enter your custom domain
4. Follow DNS configuration instructions

**✅ Checkpoint:** Your app has a public URL.

---

## Part 3: Verify Deployment (5 minutes)

### Step 3.1: Get Your App URL

1. Click on your **App service**
2. Look for the URL at the top (something like `https://your-app-name.up.railway.app`)
3. Or click "**Open App**" button

**Copy this URL - you'll need it for testing!**

---

### Step 3.2: Test Health Endpoint

Open terminal and test:

```bash
# Replace with your actual URL
curl https://your-app.up.railway.app/up

# Expected output:
# {"status":"ok"}
```

Or open in browser:
```
https://your-app.up.railway.app/up
```

**✅ If you see "ok", your app is running!**

---

### Step 3.3: Test User Registration

```bash
# Replace YOUR_APP_URL with your actual Railway URL
export APP_URL="https://your-app.up.railway.app"

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
```

**Expected:** JSON response with user data and token.

---

### Step 3.4: Test Login

```bash
curl -X POST $APP_URL/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Expected:** JSON response with JWT token.

**Copy the token from response!**

---

### Step 3.5: Test Creating a Ride

```bash
# Replace YOUR_JWT_TOKEN with actual token from login
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

**Expected:** JSON response with ride details.

**✅ If all tests pass, your deployment is successful!**

---

## Part 4: Monitor & Manage (Ongoing)

### View Logs

1. Click on your **App service**
2. Go to "**Deployments**" tab
3. Click on active deployment
4. View logs in real-time

**Or via CLI:**
```bash
railway logs
```

---

### Check Sidekiq (Background Jobs)

Your Procfile has both `web` and `worker` processes.

**To verify Sidekiq is running:**
1. Check logs for "Sidekiq" mentions
2. Or run:
```bash
railway run rails runner "puts Sidekiq::ProcessSet.new.size"
```

---

### Access Rails Console

```bash
railway run rails console
```

**Test in console:**
```ruby
# Check database
User.count

# Check Redis
$redis.ping

# Check tenant
Tenant.first
```

---

### Restart Services

If something goes wrong:

1. Go to your **App service**
2. Click three-dot menu
3. Select "**Restart**"

Or via CLI:
```bash
railway restart
```

---

### View Metrics

1. Click on your **App service**
2. Go to "**Metrics**" tab
3. See CPU, Memory, Network usage

---

## 🐛 Troubleshooting Common Issues

### Issue 1: Build Failed

**Check build logs:**
1. App service → Deployments → Click failed deployment
2. Read error messages

**Common fixes:**
- Missing gems: Check Gemfile.lock is committed
- Ruby version mismatch: Check .ruby-version file
- Assets failed: Check if node/yarn is needed

---

### Issue 2: App Crashes on Start

**Check deploy logs:**
1. Look for error messages in deploy logs

**Common fixes:**
```bash
# Missing master key
railway variables --set RAILS_MASTER_KEY="your_key"

# Database not migrated
railway run rails db:migrate

# PostGIS not enabled
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION postgis')"
```

---

### Issue 3: Database Connection Error

**Verify DATABASE_URL:**
1. PostgreSQL service → Variables → Check DATABASE_URL exists
2. App service → Variables → Should see DATABASE_URL (inherited)

**Fix:**
- Redeploy app after adding PostgreSQL
- Check PostgreSQL service is running

---

### Issue 4: Redis Connection Error

**Verify REDIS_URL:**
1. Redis service → Variables → Check REDIS_URL exists
2. App service → Variables → Should see REDIS_URL (inherited)

**Test connection:**
```bash
railway run rails runner "puts \$redis.ping"
# Should output: PONG
```

---

### Issue 5: PostGIS Extension Not Found

**Enable manually:**
```bash
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
```

Or connect via psql and run:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

---

## 📊 Deployment Checklist

Use this to verify everything:

- [ ] Code pushed to GitHub
- [ ] Railway project created
- [ ] PostgreSQL service added
- [ ] Redis service added
- [ ] All environment variables set (7 total)
- [ ] App deployed successfully
- [ ] Database migrations run
- [ ] PostGIS extension enabled
- [ ] Health endpoint returns "ok"
- [ ] Can register user via API
- [ ] Can login via API
- [ ] Can create ride via API
- [ ] Sidekiq worker is running
- [ ] Logs are accessible
- [ ] App URL is working

---

## 🎉 Success!

Your Ride Hailing App is now live at:
```
https://your-app-name.up.railway.app
```

**Share this URL with:**
- Your team for testing
- Your client for demo
- Frontend developers for API integration

---

## 📱 Next Steps

1. **Test all API endpoints** - Use Postman or curl
2. **Monitor logs** - Watch for any errors
3. **Check metrics** - Ensure app is performing well
4. **Setup monitoring** - Consider adding error tracking
5. **Configure domain** - Add your custom domain if needed

---

## 🔄 Making Updates

When you make changes to your code:

```bash
# 1. Commit changes
git add .
git commit -m "Your changes"

# 2. Push to GitHub
git push origin main

# 3. Railway auto-deploys!
# Watch deployment in Railway dashboard
```

**Railway automatically deploys on every push to main!**

---

## 💰 Cost Estimate

**Free Tier:**
- $5 credit/month
- Perfect for testing and development

**If you exceed free tier:**
- PostgreSQL: ~$5/month
- Redis: ~$1/month
- Compute: Pay as you go

**Total: ~$5-10/month for production**

---

## 🆘 Need Help?

- **Railway Docs:** https://docs.railway.app
- **Railway Discord:** https://discord.gg/railway
- **Railway Status:** https://status.railway.app
- **View Logs:** Click app → Deployments → Latest deployment

---

## ✅ You're Done!

Your ride-hailing application is:
- ✅ Deployed to Railway
- ✅ Using PostgreSQL with PostGIS
- ✅ Using Redis for caching
- ✅ Running Sidekiq for background jobs
- ✅ Accessible via public URL
- ✅ Ready for testing and development

**Congratulations! 🎉**

---

## 📖 Quick Reference

### Important URLs
- Railway Dashboard: https://railway.app/dashboard
- Your App: https://your-app.railway.app
- API Health: https://your-app.railway.app/up

### Important Commands
```bash
# View logs
railway logs

# Run migrations
railway run rails db:migrate

# Access console
railway run rails console

# Restart app
railway restart

# View variables
railway variables
```

---

**Your app is live! Start testing and building! 🚀**


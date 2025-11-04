# 🚂 Railway Quick Start - Updated Commands

## ✅ Correct Railway CLI Commands

The Railway CLI syntax has been updated. Use these commands:

---

## 🚀 Deploy in 5 Steps

### Step 1: Install and Login
```bash
# Install Railway CLI
brew install railway

# Login
railway login
```

### Step 2: Initialize Project
```bash
cd "/Users/utkarshagrawal/Desktop/Ride Hailing App"

# Initialize project (creates .railway directory)
railway init
```

### Step 3: Link PostgreSQL and Redis
```bash
# Create a new PostgreSQL database in Railway dashboard
# Then link it
railway link

# Or create via dashboard at https://railway.app/new
```

**Important:** Go to https://railway.app/new and:
1. Click "New Project"
2. Add "PostgreSQL" service
3. Add "Redis" service
4. Deploy "GitHub Repo" or "Empty Project"

### Step 4: Set Environment Variables
```bash
# Set variables using the new syntax
railway variables --set RAILS_MASTER_KEY="$(cat config/master.key)"
railway variables --set RAILS_ENV=production
railway variables --set RACK_ENV=production
railway variables --set SECRET_KEY_BASE="$(openssl rand -hex 64)"
railway variables --set RAILS_SERVE_STATIC_FILES=true
```

### Step 5: Deploy
```bash
# Commit your code
git add .
git commit -m "Deploy to Railway"

# Deploy
railway up

# Run migrations
railway run rails db:migrate

# Enable PostGIS
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
```

---

## 🎯 Alternative: Use Railway Dashboard (Easier!)

### Option A: Deploy via GitHub

1. **Push to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/ride-hailing-app.git
   git push -u origin main
   ```

2. **Deploy on Railway:**
   - Go to https://railway.app/new
   - Click "Deploy from GitHub repo"
   - Select your repository
   - Add PostgreSQL service
   - Add Redis service

3. **Set Environment Variables in Dashboard:**
   - Go to your project settings
   - Click "Variables"
   - Add:
     - `RAILS_MASTER_KEY`: (paste from config/master.key)
     - `RAILS_ENV`: production
     - `RACK_ENV`: production
     - `RAILS_SERVE_STATIC_FILES`: true

4. **Deploy triggers automatically!**

### Option B: Deploy from Local (No GitHub)

1. **Go to Railway Dashboard:**
   - Visit https://railway.app/new
   - Click "Deploy from GitHub repo" → "Deploy from local"
   - Or click "Empty Project"

2. **Add Services:**
   - Click "New" → "Database" → "Add PostgreSQL"
   - Click "New" → "Database" → "Add Redis"

3. **Deploy Your Code:**
   ```bash
   railway init
   railway up
   ```

---

## 🔧 Useful Railway Commands

### Check Variables
```bash
# List all variables
railway variables

# Get specific variable
railway variables --get RAILS_MASTER_KEY
```

### View Logs
```bash
railway logs
```

### Open App
```bash
railway open
```

### Run Commands
```bash
railway run rails console
railway run rails db:migrate
railway run rails db:seed
```

### Link to Existing Project
```bash
railway link
```

### Get Service Info
```bash
railway status
```

---

## 📝 Environment Variables Needed

Set these in Railway (Dashboard or CLI):

```bash
RAILS_MASTER_KEY=your_master_key_from_config
RAILS_ENV=production
RACK_ENV=production
SECRET_KEY_BASE=generate_with_rails_secret
RAILS_SERVE_STATIC_FILES=true

# These are auto-set by Railway when you add the services:
DATABASE_URL=automatically_set
REDIS_URL=automatically_set
```

---

## 🎯 Recommended: Dashboard Method

**Easiest way** (no CLI issues):

1. Go to https://railway.app
2. Click "New Project"
3. Choose "Deploy from GitHub repo" (or "Empty Project")
4. Add PostgreSQL database
5. Add Redis database
6. Set environment variables in dashboard
7. Deploy!

**Time: 5 minutes**

---

## 🐛 If CLI Commands Don't Work

Use the **Railway Dashboard** instead:

1. **Create Project:** https://railway.app/new
2. **Add Services:** Click "+ New" → Add PostgreSQL & Redis
3. **Set Variables:** Go to project → Variables tab
4. **Deploy:** Push to GitHub or use `railway up`

---

## ✅ After Deployment

### Get Your URL
```bash
railway domain
```

Or check in Railway Dashboard → Settings → Domains

### Test Your App
```bash
curl https://your-app.railway.app/up
```

### Enable PostGIS
```bash
railway run rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
```

---

## 💡 Pro Tip

**Use Railway Dashboard for setup**, then use CLI for daily tasks:
- ✅ Dashboard: Create project, add services, set variables
- ✅ CLI: Deploy updates, view logs, run commands

---

## 🚀 Ready to Deploy?

**Easiest Method:**
1. Visit https://railway.app/new
2. Connect GitHub or deploy empty project
3. Add PostgreSQL & Redis
4. Set environment variables
5. Done!

**Your app will be live!** 🎉


# Railway Deployment Guide

## Quick Deploy

1. **Push to GitHub:**
   ```bash
   git push origin main
   ```

2. **Create Railway Project:**
   - Go to: https://railway.app/new
   - Click "Deploy from GitHub repo"
   - Select: `Utkarsh2903/ride-hailing-app`

3. **Add Services:**
   - Click "+ New" → Database → Add PostgreSQL
   - Click "+ New" → Database → Add Redis

4. **Set Environment Variables:**
   Go to Rails app → Variables tab → Add:
   ```
   RAILS_MASTER_KEY=<paste from config/master.key>
   SECRET_KEY_BASE=<generate with: openssl rand -hex 64>
   RAILS_ENV=production
   RAILS_SERVE_STATIC_FILES=true
   ```

5. **Wait for Deployment** (~2-3 minutes)

6. **One-Time Setup:**
   In Railway Dashboard → Your app → "..." menu → "Run Command":
   ```bash
   rails runner "ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')"
   ```

7. **Create Test Data:**
   ```bash
   rails runner "
     tenant = Tenant.create!(name: 'Test Co', subdomain: 'test', status: 'active')
     User.create!(tenant: tenant, email: 'admin@test.com', password: 'password123', role: 'super_admin', status: 'active')
   "
   ```

## Get Your URL

Railway Dashboard → Settings → Domains → Copy URL

## Test Your API

```bash
curl https://your-app.railway.app/health
```

## That's It! 🚀

Your app automatically:
- ✅ Runs migrations on each deploy (via `Procfile`)
- ✅ Starts Puma web server
- ✅ Starts Sidekiq workers
- ✅ Connects to PostgreSQL and Redis

## Troubleshooting

**App crashes?** Check Railway logs:
- Dashboard → Your app → Deployments → View logs

**Database issues?** Verify:
- PostgreSQL service is running
- `DATABASE_URL` is set (auto-configured)

**Redis issues?** Verify:
- Redis service is running
- `REDIS_URL` is set (auto-configured)


# 🔄 Railway Fresh Database Setup

Your database has partial migrations. Here's how to start fresh on Railway:

---

## **Option 1: Delete and Recreate PostgreSQL Service (Easiest)**

### **Steps:**

1. **Go to Railway Dashboard:** https://railway.app/dashboard
2. **Click your PostgreSQL service**
3. **Click "Settings" tab**
4. **Scroll to bottom → Click "Delete Service"**
5. **Confirm deletion** (all data will be lost - that's OK, it's corrupted anyway)
6. **Click "+ New" button**
7. **Select "Database" → "Add PostgreSQL"**
8. **Wait ~30 seconds for provisioning**
9. **Railway automatically connects it to your app!**
10. **Your app will redeploy automatically**

✅ **Done!** Fresh database with all migrations applied correctly.

---

## **Option 2: Manual Database Drop (If you can access psql)**

If Railway provides a way to run SQL commands:

```sql
-- Drop all tables
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
```

Then trigger a redeploy of your Rails app.

---

## **What Happens Next**

Once you have a fresh PostgreSQL service:

1. ✅ Railway redeploys your Rails app
2. ✅ Runs `rails db:prepare` (creates tables)
3. ✅ All migrations run successfully
4. ✅ App starts on port 8080

---

## **Verify It Worked**

```bash
# Health check
curl https://your-app.railway.app/health
# Should return: 200 OK
```

---

## **Create Test Data**

After deployment succeeds, create tenant and user:

**Railway Dashboard → Your Rails App → "..." → "Run Command":**

```bash
rails runner "
tenant = Tenant.create!(
  subdomain: 'test',
  name: 'Test Company',
  status: 'active',
  default_payment_provider: 'stripe'
)

user = User.create!(
  tenant: tenant,
  email: 'admin@test.com',
  password: 'password123',
  role: 'super_admin',
  status: 'active'
)

puts '✅ Created tenant: ' + tenant.subdomain
puts '✅ Created user: ' + user.email
"
```

---

## **Test Login**

```bash
curl -X POST https://your-app.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: test" \
  -d '{
    "email": "admin@test.com",
    "password": "password123"
  }'
```

Should return a JWT token! 🎉

---

**Recommendation: Use Option 1** - fastest and cleanest way to start fresh.


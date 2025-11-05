# 🚀 Swagger Quick Start

Get started with API testing in 2 minutes!

---

## **Step 1: Access Swagger UI**

### **Railway (Deployed):**
```
https://your-app.railway.app/api-docs
```

### **Local:**
```
http://localhost:8080/api-docs
```

---

## **Step 2: Login**

1. Find **`POST /api/v1/auth/login`** in Swagger UI
2. Click **"Try it out"**
3. Enter header: `X-Tenant-ID: test`
4. Enter body:
```json
{
  "email": "admin@test.com",
  "password": "password123"
}
```
5. Click **"Execute"**
6. Copy the **`token`** from response

---

## **Step 3: Authorize**

1. Click the **"Authorize"** button (top right)
2. In **Bearer** field, paste your token
3. In **TenantID** field, enter: `test`
4. Click **"Authorize"**
5. Click **"Close"**

---

## **Step 4: Test Any API!**

Now you can test all endpoints:
- ✅ Create rides
- ✅ Update driver location
- ✅ Process payments
- ✅ Manage trips
- ✅ View statistics

---

## **📚 Full Documentation**

See **`SWAGGER_GUIDE.md`** for:
- Complete API reference
- Test scenarios
- Troubleshooting
- Best practices

---

## **🧪 Quick Test - Create a Ride**

1. Go to **`POST /api/v1/rides`**
2. Click **"Try it out"**
3. Use this body:
```json
{
  "pickup_latitude": 12.9716,
  "pickup_longitude": 77.5946,
  "dropoff_latitude": 12.9141,
  "dropoff_longitude": 77.6412,
  "tier": "standard",
  "payment_method": "card"
}
```
4. Click **"Execute"**
5. ✅ See your ride request!

---

**That's it! Start testing your APIs now! 🎉**


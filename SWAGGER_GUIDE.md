# 📚 Swagger API Documentation Guide

Complete interactive API documentation with testing capabilities using Swagger UI.

---

## 🚀 Access Swagger Documentation

### **Local:**
```
http://localhost:8080/api-docs
```

### **Railway:**
```
https://your-app.railway.app/api-docs
```

---

## 📖 Available API Groups

### **1. Authentication** 🔐
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login and get JWT token
- `GET /api/v1/auth/me` - Get current user
- `POST /api/v1/auth/logout` - Logout

### **2. Rides** 🚗
- `POST /api/v1/rides` - Create ride request
- `GET /api/v1/rides` - List rides
- `GET /api/v1/rides/{id}` - Get ride details
- `POST /api/v1/rides/{id}/cancel` - Cancel ride
- `GET /api/v1/rides/{id}/track` - Track ride in real-time

### **3. Drivers** 👨‍✈️
- `POST /api/v1/drivers/{id}/location` - Update location (1-2/sec)
- `POST /api/v1/drivers/{id}/accept` - Accept ride
- `POST /api/v1/drivers/{id}/decline` - Decline ride
- `POST /api/v1/drivers/{id}/arrive` - Mark arrived
- `POST /api/v1/drivers/{id}/start_trip` - Start trip
- `POST /api/v1/drivers/{id}/online` - Go online
- `POST /api/v1/drivers/{id}/offline` - Go offline
- `GET /api/v1/drivers/{id}/earnings` - Get earnings

### **4. Trips** 🛣️
- `GET /api/v1/trips/{id}` - Get trip details
- `POST /api/v1/trips/{id}/end` - End trip

### **5. Payments** 💳
- `POST /api/v1/payments` - Create payment
- `GET /api/v1/payments` - List payments
- `GET /api/v1/payments/{id}` - Get payment details
- `POST /api/v1/payments/{id}/retry` - Retry payment
- `POST /api/v1/payments/{id}/refund` - Refund payment

### **6. Tenants** 🏢
- `GET /api/v1/tenants` - List tenants
- `POST /api/v1/tenants` - Create tenant
- `GET /api/v1/tenants/{id}` - Get tenant
- `PATCH /api/v1/tenants/{id}` - Update tenant
- `DELETE /api/v1/tenants/{id}` - Delete tenant
- `GET /api/v1/tenants/{id}/stats` - Get stats

---

## 🧪 How to Test APIs

### **Step 1: Generate Swagger Documentation**

**On Railway (automatic):**
- Swagger docs are generated automatically on deployment
- Just visit `/api-docs`

**Locally:**
```bash
RAILS_ENV=production bundle exec rake rswag:specs:swaggerize
```

### **Step 2: Access Swagger UI**

Open your browser:
- **Local:** http://localhost:8080/api-docs
- **Railway:** https://your-app.railway.app/api-docs

### **Step 3: Authentication**

1. **Login to get JWT token:**
   - Find `POST /api/v1/auth/login` endpoint
   - Click "Try it out"
   - Enter:
     ```json
     {
       "email": "admin@test.com",
       "password": "password123"
     }
     ```
   - Add header: `X-Tenant-ID: test`
   - Click "Execute"
   - Copy the `token` from response

2. **Set Authorization:**
   - Click the **"Authorize"** button at the top
   - In "Bearer" field, paste: `YOUR_JWT_TOKEN`
   - In "TenantID" field, enter: `test`
   - Click "Authorize"
   - Click "Close"

### **Step 4: Test Any Endpoint**

Now you can test any endpoint:
1. Select an endpoint
2. Click "Try it out"
3. Fill in required parameters
4. Click "Execute"
5. See the response!

---

## 📝 Common Test Scenarios

### **Scenario 1: Create a Ride Request (Rider)**

1. Login as rider
2. Go to `POST /api/v1/rides`
3. Click "Try it out"
4. Use this body:
```json
{
  "pickup_latitude": 12.9716,
  "pickup_longitude": 77.5946,
  "pickup_address": "Koramangala, Bangalore",
  "dropoff_latitude": 12.9141,
  "dropoff_longitude": 77.6412,
  "dropoff_address": "Whitefield, Bangalore",
  "tier": "standard",
  "payment_method": "card"
}
```
5. Execute
6. Note the `ride_id` from response

### **Scenario 2: Update Driver Location**

1. Login as driver
2. Go to `POST /api/v1/drivers/{id}/location`
3. Replace `{id}` with driver ID
4. Body:
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "bearing": 45.5,
  "speed": 30.0,
  "accuracy": 10.0
}
```
5. Execute

### **Scenario 3: Complete Full Ride Flow**

1. **Create ride** - `POST /api/v1/rides`
2. **Accept ride** - `POST /api/v1/drivers/{id}/accept`
3. **Arrive at pickup** - `POST /api/v1/drivers/{id}/arrive`
4. **Start trip** - `POST /api/v1/drivers/{id}/start_trip`
5. **End trip** - `POST /api/v1/trips/{id}/end`
6. **Process payment** - `POST /api/v1/payments`

---

## 🔑 Required Headers

### **All Endpoints:**
- `X-Tenant-ID: test` (or your tenant subdomain)

### **Protected Endpoints:**
- `Authorization: Bearer YOUR_JWT_TOKEN`

### **Idempotent Operations:**
- `Idempotency-Key: unique-uuid` (optional, prevents duplicates)

---

## 💡 Tips

### **1. Test Data:**
After deployment, create test users:
```bash
# In Railway → "Run Command"
rails runner "
tenant = Tenant.find_by(subdomain: 'test')
rider_user = User.create!(tenant: tenant, email: 'rider@test.com', phone: '+1111111111', password: 'password123', name: 'Test Rider', role: 'rider', status: 'active')
Rider.create!(user: rider_user, rating: 5.0)

driver_user = User.create!(tenant: tenant, email: 'driver@test.com', phone: '+2222222222', password: 'password123', name: 'Test Driver', role: 'driver', status: 'active')
Driver.create!(user: driver_user, license_number: 'DL123', vehicle_type: 'standard', status: 'offline')
"
```

### **2. Pagination:**
Most list endpoints support:
- `?page=1`
- `?per_page=20`

### **3. Filtering:**
Many endpoints support status filtering:
- `?status=active`
- `?status=completed`

### **4. Idempotency:**
For create operations, use `Idempotency-Key` header to prevent duplicates:
```
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

---

## 🐛 Troubleshooting

### **Issue: "Failed to fetch"**
- Check if server is running
- Verify URL is correct
- Check CORS settings

### **Issue: "401 Unauthorized"**
- JWT token expired (login again)
- Wrong `Authorization` header format
- Missing `Bearer` prefix

### **Issue: "403 Forbidden"**
- Insufficient permissions
- Wrong tenant ID
- Resource doesn't belong to your tenant

### **Issue: "422 Validation Error"**
- Check required fields
- Verify data types
- See error message for details

---

## 📊 Response Codes

- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success with no body
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Permission denied
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation failed
- `500 Internal Server Error` - Server error

---

## 🔗 Quick Links

- **Swagger UI:** `/api-docs`
- **Health Check:** `/health`
- **API Base:** `/api/v1`

---

**Happy Testing! 🚀**


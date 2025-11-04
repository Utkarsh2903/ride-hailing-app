# Redis-based cache for driver locations
# Implements Caching Pattern for high-performance location lookups
# Optimized for 1-2 updates per second per driver
class DriverLocationCache
  CACHE_TTL = 300.seconds  # 5 minutes
  LOCATION_KEY_PREFIX = 'driver_location'
  STREAM_KEY_PREFIX = 'location_stream'
  RATE_LIMIT_KEY_PREFIX = 'location_rate_limit'
  MAX_UPDATES_PER_SECOND = 2

  class << self
    # Enhanced update with tenant awareness and rate limiting
    def update_location(driver_id:, latitude:, longitude:, bearing: nil, speed: nil, 
                       accuracy: nil, tenant_id: nil)
      # Rate limiting (max 2 updates/second)
      return false unless check_rate_limit(driver_id)
      
      tenant_id ||= Tenant.current_id
      timestamp = Time.current.to_f
      
      redis.pipelined do |pipe|
        # 1. Geospatial index (for nearby searches)
        pipe.geoadd(
          available_drivers_set_key(tenant_id),
          longitude,
          latitude,
          driver_id
        )

        # 2. Detailed location hash
        location_key = location_hash_key(tenant_id, driver_id)
        pipe.hset(location_key, {
          latitude: latitude,
          longitude: longitude,
          bearing: bearing,
          speed: speed,
          accuracy: accuracy,
          updated_at: timestamp
        })
        pipe.expire(location_key, CACHE_TTL)
        
        # 3. Add to stream for batch persistence
        pipe.xadd(
          stream_key(tenant_id),
          {
            driver_id: driver_id,
            lat: latitude,
            lng: longitude,
            bearing: bearing,
            speed: speed,
            timestamp: timestamp
          },
          maxlen: 10000,
          approximate: true
        )
        
        # 4. Publish for real-time subscribers
        pipe.publish(
          "tenant:#{tenant_id}:driver:#{driver_id}:location",
          {
            driver_id: driver_id,
            latitude: latitude,
            longitude: longitude,
            bearing: bearing,
            speed: speed,
            timestamp: timestamp
          }.to_json
        )
      end
      
      # Increment metrics
      increment_update_counter(tenant_id)
      
      true
    end

    def nearby_drivers(latitude, longitude, radius_km, limit = 20, tenant_id: nil)
      tenant_id ||= Tenant.current_id
      
      # Use Redis GEORADIUS for fast spatial queries
      driver_ids = redis.georadius(
        available_drivers_set_key(tenant_id),
        longitude,
        latitude,
        radius_km,
        'km',
        withdist: true,
        count: limit * 2,  # Get extra for filtering
        sort: 'asc'
      )

      driver_ids.map do |driver_id, distance|
        location_data = get_location(driver_id, tenant_id: tenant_id)
        next unless location_data
        
        # Filter stale locations (>5 minutes old)
        next if Time.current.to_f - location_data['updated_at'].to_f > CACHE_TTL

        {
          driver_id: driver_id,
          distance: distance.to_f.round(2),
          latitude: location_data['latitude'].to_f,
          longitude: location_data['longitude'].to_f,
          bearing: location_data['bearing']&.to_f,
          speed: location_data['speed']&.to_f,
          accuracy: location_data['accuracy']&.to_f,
          last_update: Time.at(location_data['updated_at'].to_f)
        }
      end.compact.first(limit)
    end

    def get_location(driver_id, tenant_id: nil)
      tenant_id ||= Tenant.current_id
      location_key = location_hash_key(tenant_id, driver_id)
      redis.hgetall(location_key)
    end

    def remove_driver(driver_id, tenant_id: nil)
      tenant_id ||= Tenant.current_id
      redis.pipelined do |pipe|
        pipe.zrem(available_drivers_set_key(tenant_id), driver_id)
        pipe.del(location_hash_key(tenant_id, driver_id))
      end
    end

    def count_available_drivers(latitude, longitude, radius_km, tenant_id: nil)
      tenant_id ||= Tenant.current_id
      redis.georadius(
        available_drivers_set_key(tenant_id),
        longitude,
        latitude,
        radius_km,
        'km'
      ).count
    end
    
    # Rate limiting check
    def check_rate_limit(driver_id)
      key = "#{RATE_LIMIT_KEY_PREFIX}:#{driver_id}"
      count = redis.incr(key)
      redis.expire(key, 1) if count == 1
      count <= MAX_UPDATES_PER_SECOND
    end
    
    # Metrics
    def increment_update_counter(tenant_id)
      key = "tenant:#{tenant_id}:metrics:location_updates:#{Date.current}"
      redis.incr(key)
      redis.expire(key, 7.days)
    end
    
    def location_updates_today(tenant_id)
      key = "tenant:#{tenant_id}:metrics:location_updates:#{Date.current}"
      redis.get(key).to_i
    end

    def bulk_update_locations(locations)
      # Batch update for efficiency
      pipeline = redis.pipelined do |pipe|
        locations.each do |loc|
          pipe.geoadd(
            AVAILABLE_DRIVERS_SET,
            loc[:longitude],
            loc[:latitude],
            loc[:driver_id]
          )

          location_key = "#{LOCATION_KEY_PREFIX}:#{loc[:driver_id]}"
          pipe.hset(location_key, {
            latitude: loc[:latitude],
            longitude: loc[:longitude],
            bearing: loc[:bearing],
            speed: loc[:speed],
            updated_at: Time.current.to_i
          })
          pipe.expire(location_key, CACHE_TTL)
        end
      end

      pipeline
    end

    private

    def redis
      $redis  # Use global Redis connection
    end
    
    # Tenant-namespaced keys
    def available_drivers_set_key(tenant_id)
      "tenant:#{tenant_id}:available_drivers"
    end
    
    def location_hash_key(tenant_id, driver_id)
      "tenant:#{tenant_id}:#{LOCATION_KEY_PREFIX}:#{driver_id}"
    end
    
    def stream_key(tenant_id)
      "tenant:#{tenant_id}:#{STREAM_KEY_PREFIX}"
    end
  end
end


# Service for calculating dynamic surge pricing
# Implements Strategy Pattern for different surge calculation methods
class SurgePricingService < ApplicationService
  MIN_MULTIPLIER = 1.0
  MAX_MULTIPLIER = 5.0
  HIGH_DEMAND_THRESHOLD = 1.5
  VERY_HIGH_DEMAND_THRESHOLD = 3.0

  def initialize(latitude:, longitude:, tier: 'standard')
    @latitude = latitude
    @longitude = longitude
    @tier = tier
  end

  def call
    # Calculate dynamic surge based on real-time supply/demand
    multiplier = calculate_dynamic_surge
    zone_name = 'dynamic'

    success(
      surge_multiplier: multiplier,
      zone_name: zone_name,
      surge_active: multiplier > MIN_MULTIPLIER,
      message: surge_message(multiplier)
    )
  rescue StandardError => e
    failure("Surge calculation failed: #{e.message}")
  end

  private

  def calculate_dynamic_surge
    demand = count_active_rides_nearby
    supply = count_available_drivers_nearby

    return MIN_MULTIPLIER if supply.zero? && demand.zero?
    return MAX_MULTIPLIER if supply.zero? && demand > 0

    ratio = demand.to_f / supply

    determine_multiplier(ratio)
  end

  def count_active_rides_nearby(radius_km = 5)
    # Use Redis cache for real-time counts
    cache_key = "active_rides:#{@latitude}:#{@longitude}:#{radius_km}"
    
    Rails.cache.fetch(cache_key, expires_in: 30.seconds) do
      Ride.active
          .where(
            "ST_DWithin(
              pickup_location,
              ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
              ?
            )",
            @longitude, @latitude, radius_km * 1000
          )
          .count
    end
  end

  def count_available_drivers_nearby(radius_km = 5)
    # Use Redis cache for real-time counts
    cache_key = "available_drivers:#{@latitude}:#{@longitude}:#{radius_km}"
    
    Rails.cache.fetch(cache_key, expires_in: 30.seconds) do
      DriverLocationCache.count_available_drivers(@latitude, @longitude, radius_km)
    end
  end

  def determine_multiplier(ratio)
    multiplier = case ratio
                 when 0..0.5
                   MIN_MULTIPLIER
                 when 0.5..1.0
                   1.2
                 when 1.0..1.5
                   1.5
                 when 1.5..2.0
                   2.0
                 when 2.0..3.0
                   2.5
                 when 3.0..4.0
                   3.5
                 else
                   MAX_MULTIPLIER
                 end

    # Tier-based adjustments
    tier_adjustment = tier_multiplier_adjustment
    adjusted = multiplier * tier_adjustment

    [[adjusted, MIN_MULTIPLIER].max, MAX_MULTIPLIER].min.round(2)
  end

  def tier_multiplier_adjustment
    case @tier
    when 'economy'
      0.9
    when 'standard'
      1.0
    when 'premium'
      1.1
    when 'suv', 'luxury'
      1.2
    else
      1.0
    end
  end

  def surge_message(multiplier)
    case multiplier
    when MIN_MULTIPLIER
      'Normal pricing'
    when MIN_MULTIPLIER..1.5
      'Slightly busy'
    when 1.5..2.5
      'High demand - fares are higher'
    when 2.5..4.0
      'Very high demand - fares are much higher'
    else
      'Extreme demand - fares are at maximum'
    end
  end
end


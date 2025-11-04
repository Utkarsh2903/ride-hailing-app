# Service for tenant-specific operations
class TenantService
  attr_reader :tenant

  def initialize(tenant)
    @tenant = tenant
  end

  def self.call(tenant, &block)
    new(tenant).instance_eval(&block)
  end

  # Get configuration values
  def config(key)
    tenant.setting(key)
  end

  def pricing_config(key)
    tenant.pricing_setting(key)
  end

  def feature_enabled?(feature)
    tenant.feature_enabled?(feature)
  end

  # Pricing calculations using tenant config
  def calculate_base_fare(tier)
    tenant.base_fare_for_tier(tier)
  end

  def calculate_per_km_rate(tier)
    tenant.per_km_rate_for_tier(tier)
  end

  def calculate_fare(distance_km, duration_minutes, tier)
    base = calculate_base_fare(tier)
    per_km = calculate_per_km_rate(tier)
    per_minute = tenant.pricing_setting('per_minute_rate') || 0.25
    minimum = tenant.pricing_setting('minimum_fare') || 5.00

    total = base + (distance_km * per_km) + (duration_minutes * per_minute)
    [total, minimum].max.round(2)
  end

  # Business rules
  def max_search_radius
    tenant.setting('operational')&.dig('max_search_radius_km') || 10
  end

  def driver_timeout_seconds
    tenant.setting('operational')&.dig('driver_timeout_seconds') || 30
  end

  def ride_timeout_minutes
    tenant.setting('operational')&.dig('ride_timeout_minutes') || 15
  end

  def min_driver_rating
    tenant.setting('business_rules')&.dig('min_driver_rating') || 4.0
  end

  def max_driver_rejections
    tenant.setting('business_rules')&.dig('max_driver_rejections') || 3
  end

  def cancellation_fee
    tenant.pricing_setting('cancellation_fee') || 5.00
  end

  # Quota checks
  def can_add_driver?
    tenant.within_driver_limit?
  end

  def can_add_rider?
    tenant.within_rider_limit?
  end

  def can_create_ride?
    tenant.within_ride_limit?
  end

  # Subscription checks
  def subscription_active?
    tenant.subscription_active?
  end

  def days_until_expiration
    return nil if tenant.subscription_ends_at.nil?
    ((tenant.subscription_ends_at - Time.current) / 1.day).to_i
  end

  def subscription_expiring_soon?
    return false unless subscription_active?
    days = days_until_expiration
    days && days <= 7
  end

  # Payment methods
  def supported_payment_methods
    tenant.pricing_setting('payment')&.dig('supported_methods') || %w[card cash]
  end

  def payment_method_supported?(method)
    supported_payment_methods.include?(method.to_s)
  end

  # Surge pricing
  def surge_enabled?
    tenant.surge_enabled?
  end

  def max_surge_multiplier
    tenant.max_surge_multiplier
  end

  def apply_surge_limit(multiplier)
    [[multiplier, 1.0].max, max_surge_multiplier].min
  end

  # Statistics
  def total_rides
    tenant.rides.count
  end

  def total_drivers
    tenant.drivers.count
  end

  def total_riders
    tenant.riders.count
  end

  def active_drivers
    tenant.drivers.where(status: 'online').count
  end

  def rides_today
    tenant.rides.where('created_at >= ?', Time.current.beginning_of_day).count
  end

  def revenue_today
    tenant.payments
      .where('created_at >= ?', Time.current.beginning_of_day)
      .where(status: 'completed')
      .sum(:amount)
  end

  def revenue_this_month
    tenant.payments
      .where('created_at >= ?', Time.current.beginning_of_month)
      .where(status: 'completed')
      .sum(:amount)
  end
end


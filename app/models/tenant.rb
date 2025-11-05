# == Schema Information
#
# Table name: tenants
#
#  id                     :uuid             not null, primary key
#  slug                   :string           not null
#  name                   :string           not null
#  subdomain              :string
#  status                 :string           default("active"), not null
#  region                 :string
#  country_code           :string(3)
#  timezone               :string           default("UTC")
#  currency               :string(3)        default("USD")
#  settings               :jsonb
#  pricing_config         :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Tenant < ApplicationRecord
  # Associations
  has_many :users, dependent: :destroy
  has_many :drivers, dependent: :destroy
  has_many :riders, dependent: :destroy
  has_many :rides, dependent: :destroy
  has_many :trips, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :driver_locations, dependent: :destroy
  has_many :driver_assignments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Validations
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :subdomain, uniqueness: { allow_blank: true }, format: { with: /\A[a-z0-9-]+\z/, allow_blank: true }
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended trial] }
  validates :currency, format: { with: /\A[A-Z]{3}\z/, allow_blank: true }
  validates :country_code, format: { with: /\A[A-Z]{2,3}\z/, allow_blank: true }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :suspended, -> { where(status: 'suspended') }
  scope :by_region, ->(region) { where(region: region) }
  scope :by_country, ->(code) { where(country_code: code) }

  # Callbacks
  before_validation :set_defaults, on: :create
  before_validation :normalize_slug

  # Class methods
  class << self
    def find_by_subdomain(subdomain)
      find_by(subdomain: subdomain)
    end

    def find_by_custom_domain(domain)
      find_by(custom_domain: domain)
    end

    def find_by_slug(slug)
      find_by(slug: slug)
    end

    # Current tenant (thread-safe)
    def current
      Thread.current[:current_tenant]
    end

    def current=(tenant)
      Thread.current[:current_tenant] = tenant
    end

    def current_id
      current&.id
    end

    # Execute block within tenant context
    def with_tenant(tenant)
      previous_tenant = current
      self.current = tenant
      yield
    ensure
      self.current = previous_tenant
    end
  end

  # Instance methods
  def active?
    status == 'active'
  end

  def suspended?
    status == 'suspended'
  end

  def inactive?
    status == 'inactive'
  end

  def trial?
    status == 'trial'
  end

  def setting(key)
    settings&.dig(key.to_s)
  end

  def pricing_setting(key)
    pricing_config&.dig(key.to_s)
  end

  # Get base fare for tier
  def base_fare_for_tier(tier)
    pricing_config.dig('base_fares', tier) || default_base_fare
  end

  # Get per km rate for tier
  def per_km_rate_for_tier(tier)
    pricing_config.dig('per_km_rates', tier) || default_per_km_rate
  end

  def default_base_fare
    pricing_config.dig('default_base_fare') || 3.50
  end

  def default_per_km_rate
    pricing_config.dig('default_per_km_rate') || 1.50
  end

  def surge_enabled?
    pricing_config.dig('surge_enabled') != false
  end

  def max_surge_multiplier
    pricing_config.dig('surge_max_multiplier') || 3.0
  end

  private

  def set_defaults
    self.settings ||= default_settings
    self.pricing_config ||= default_pricing_config
    self.timezone ||= 'UTC'
    self.currency ||= 'USD'
    self.status ||= 'active'
  end

  def normalize_slug
    self.slug = slug.downcase.strip.gsub(/\s+/, '-') if slug.present?
  end

  def default_settings
    {
      'operational' => {
        'max_search_radius_km' => 10,
        'driver_timeout_seconds' => 30,
        'ride_timeout_minutes' => 15,
        'max_active_rides_per_rider' => 1,
        'max_active_rides_per_driver' => 1
      },
      'business_rules' => {
        'min_driver_rating' => 4.0,
        'require_driver_verification' => true,
        'require_rider_verification' => false,
        'allow_driver_rejection' => true,
        'max_driver_rejections' => 3
      }
    }
  end

  def default_pricing_config
    {
      'base_fares' => {
        'economy' => 2.50,
        'standard' => 3.50,
        'premium' => 5.00,
        'suv' => 6.00,
        'luxury' => 10.00
      },
      'per_km_rates' => {
        'economy' => 1.00,
        'standard' => 1.50,
        'premium' => 2.50,
        'suv' => 3.00,
        'luxury' => 5.00
      },
      'per_minute_rate' => 0.25,
      'minimum_fare' => 5.00,
      'cancellation_fee' => 5.00,
      'surge_enabled' => true,
      'surge_max_multiplier' => 3.0
    }
  end
end


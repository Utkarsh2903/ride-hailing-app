# == Schema Information
#
# Table name: driver_locations
#
#  id          :uuid             not null, primary key
#  driver_id   :uuid             not null
#  latitude    :decimal(10, 6)   not null
#  longitude   :decimal(10, 6)   not null
#  bearing     :decimal(5, 2)
#  speed       :decimal(5, 2)
#  accuracy    :decimal(5, 2)
#  recorded_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class DriverLocation < ApplicationRecord
  include TenantScoped
  # Associations
  belongs_to :driver

  # Validations
  validates :latitude, :longitude, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :recorded_at, presence: true

  # Scopes
  scope :recent, -> { order(recorded_at: :desc) }
  scope :since, ->(time) { where('recorded_at >= ?', time) }

  # Class methods - using Haversine formula for distance calculations
  def self.nearby_drivers(latitude, longitude, radius_km = 5, limit = 20)
    # Get all recent driver locations and filter by distance
    all_locations = joins(:driver)
      .where(drivers: { status: 'online' })
      .recent
    
    # Calculate distance for each and filter
    nearby = all_locations.select do |location|
      location.distance_to(latitude, longitude) <= radius_km
    end
    
    # Sort by distance and limit
    nearby.sort_by { |loc| loc.distance_to(latitude, longitude) }.take(limit)
  end

  # Instance methods - Haversine formula for distance calculation
  def distance_to(latitude, longitude)
    return nil unless self.latitude && self.longitude

    rad_per_deg = Math::PI / 180
    rm = 6371 # Earth radius in kilometers

    dlat_rad = (latitude - self.latitude) * rad_per_deg
    dlon_rad = (longitude - self.longitude) * rad_per_deg

    lat1_rad = self.latitude * rad_per_deg
    lat2_rad = latitude * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    (rm * c).round(2)
  end
end


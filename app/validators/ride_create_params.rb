# Validator for ride creation parameters
class RideCreateParams
  include BaseValidator

  attr_accessor :pickup_latitude, :pickup_longitude, :pickup_address,
                :dropoff_latitude, :dropoff_longitude, :dropoff_address,
                :tier, :payment_method

  # Coordinate validations using base validator
  validates_coordinate :pickup_latitude, type: :latitude
  validates_coordinate :pickup_longitude, type: :longitude
  validates_coordinate :dropoff_latitude, type: :latitude
  validates_coordinate :dropoff_longitude, type: :longitude

  # Address validations
  validates :pickup_address, :dropoff_address,
            presence: { message: "is required" },
            length: {
              minimum: 5,
              maximum: 255,
              message: "must be between 5 and 255 characters"
            }

  # Enum validations using base validator
  validates_enum :tier, 
                 values: %w[economy standard premium suv luxury],
                 allow_nil: true

  validates_enum :payment_method,
                 values: %w[card cash wallet],
                 allow_nil: true

  # Custom business logic validations
  validate :different_pickup_and_dropoff
  validate :reasonable_distance

  # Convert to service-ready hash
  def to_h
    {
      pickup_latitude: pickup_latitude.to_f,
      pickup_longitude: pickup_longitude.to_f,
      pickup_address: pickup_address,
      dropoff_latitude: dropoff_latitude.to_f,
      dropoff_longitude: dropoff_longitude.to_f,
      dropoff_address: dropoff_address,
      tier: tier || 'standard',
      payment_method: payment_method || 'card'
    }
  end

  private

  def different_pickup_and_dropoff
    return unless pickup_latitude && dropoff_latitude && pickup_longitude && dropoff_longitude

    if pickup_latitude.to_f == dropoff_latitude.to_f && pickup_longitude.to_f == dropoff_longitude.to_f
      errors.add(:base, 'Pickup and dropoff locations must be different')
    end
  end

  def reasonable_distance
    return unless pickup_latitude && dropoff_latitude && pickup_longitude && dropoff_longitude

    distance = calculate_distance(
      pickup_latitude.to_f, pickup_longitude.to_f,
      dropoff_latitude.to_f, dropoff_longitude.to_f
    )

    if distance > 500
      errors.add(:base, 'Distance between pickup and dropoff is too large (max 500km)')
    elsif distance < 0.1
      errors.add(:base, 'Distance between pickup and dropoff is too small (min 100m)')
    end
  end

  def calculate_distance(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI / 180
    rm = 6371 # Earth radius in kilometers

    dlat_rad = (lat2 - lat1) * rad_per_deg
    dlon_rad = (lon2 - lon1) * rad_per_deg

    lat1_rad = lat1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c
  end
end

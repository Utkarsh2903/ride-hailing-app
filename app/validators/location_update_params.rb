# Validator for driver location update parameters
class LocationUpdateParams
  include BaseValidator

  attr_accessor :latitude, :longitude, :bearing, :speed, :accuracy, :altitude

  # Coordinate validations using base validator
  validates_coordinate :latitude, type: :latitude
  validates_coordinate :longitude, type: :longitude

  # Optional fields with validation using base validator
  validates_positive_number :bearing, max: 360, allow_nil: true
  validates_positive_number :speed, max: 200, allow_nil: true    # km/h
  validates_positive_number :accuracy, max: 100, allow_nil: true # meters

  # Altitude validation (can be negative)
  validates :altitude,
            numericality: {
              greater_than_or_equal_to: -500,
              less_than_or_equal_to: 9000,
              message: "must be between -500 and 9000 meters"
            },
            allow_nil: true

  # Convert to service-ready hash
  def to_h
    {
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      bearing: bearing&.to_f,
      speed: speed&.to_f,
      accuracy: accuracy&.to_f,
      altitude: altitude&.to_f
    }
  end
end

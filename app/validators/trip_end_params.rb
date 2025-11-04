# Validator for trip end parameters
class TripEndParams
  include BaseValidator

  attr_accessor :actual_distance, :actual_duration

  # Distance validation (positive number, max 1000km)
  validates_positive_number :actual_distance, max: 1000, allow_nil: false

  # Duration validation (positive number, max 1440 minutes = 24 hours)
  validates_positive_number :actual_duration, max: 1440, allow_nil: false

  # Convert to service-ready hash
  def to_h
    {
      actual_distance: actual_distance.to_f,
      actual_duration: actual_duration.to_i
    }
  end
end

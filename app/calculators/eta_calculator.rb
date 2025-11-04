# Calculator for estimating time of arrival
# Pure calculation logic with no side effects
class EtaCalculator
  AVERAGE_SPEED_KMH = 30

  def self.call(driver, pickup_latitude, pickup_longitude)
    new(driver, pickup_latitude, pickup_longitude).calculate
  end

  def initialize(driver, pickup_latitude, pickup_longitude)
    @driver = driver
    @pickup_lat = pickup_latitude
    @pickup_lng = pickup_longitude
  end

  def calculate
    return nil unless location

    {
      distance_km: distance,
      eta_minutes: eta_minutes,
      estimated_arrival: estimated_arrival
    }
  end

  private

  def location
    @location ||= @driver.current_location
  end

  def distance
    @distance ||= location.distance_to(@pickup_lat, @pickup_lng)
  end

  def eta_minutes
    (distance / AVERAGE_SPEED_KMH * 60).round(0)
  end

  def estimated_arrival
    eta_minutes.minutes.from_now.iso8601
  end
end


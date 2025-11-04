# Service for matching riders with available drivers
# Implements Strategy Pattern for different matching algorithms
class DriverMatchingService < ApplicationService
  SEARCH_RADIUS_KM = 5
  MAX_DRIVERS_TO_NOTIFY = 10
  MATCHING_TIMEOUT = 60.seconds

  def initialize(ride)
    @ride = ride
    @pickup_lat = ride.pickup_latitude
    @pickup_lng = ride.pickup_longitude
  end

  def call
    return failure('Ride not in correct state') unless @ride.requested? || @ride.searching?

    # Mark ride as searching
    @ride.start_searching! if @ride.may_start_searching?

    # Find nearby available drivers
    nearby_drivers = find_nearby_drivers

    return failure('No drivers available nearby') if nearby_drivers.empty?

    # Score and rank drivers
    ranked_drivers = rank_drivers(nearby_drivers)

    # Send offers to top drivers
    offers = send_driver_offers(ranked_drivers)

    success(
      drivers_found: nearby_drivers.count,
      offers_sent: offers.count,
      assignments: offers
    )
  rescue StandardError => e
    failure("Matching failed: #{e.message}")
  end

  private

  def find_nearby_drivers
    # Use Redis cache first for active driver locations
    cached_drivers = DriverLocationCache.nearby_drivers(@pickup_lat, @pickup_lng, SEARCH_RADIUS_KM)
    
    if cached_drivers.any?
      return cached_drivers
    end

    # Fallback to database query with PostGIS
    DriverLocation
      .nearby_drivers(@pickup_lat, @pickup_lng, SEARCH_RADIUS_KM, MAX_DRIVERS_TO_NOTIFY)
      .map(&:driver)
      .select { |d| d.verified? && d.available? }
  end

  def rank_drivers(drivers)
    drivers.map do |driver|
      score = calculate_driver_score(driver)
      { driver: driver, score: score }
    end.sort_by { |d| -d[:score] }.take(MAX_DRIVERS_TO_NOTIFY)
  end

  def calculate_driver_score(driver)
    # Multi-factor scoring algorithm
    location = driver.current_location
    return 0 unless location

    distance_score = calculate_distance_score(location)
    rating_score = driver.rating * 10
    acceptance_score = driver.acceptance_rate / 10.0
    
    # Weighted scoring
    (distance_score * 0.5) + (rating_score * 0.3) + (acceptance_score * 0.2)
  end

  def calculate_distance_score(location)
    distance_km = location.distance_to(@pickup_lat, @pickup_lng)
    return 0 if distance_km > SEARCH_RADIUS_KM
    
    # Closer drivers get higher scores (inverse relationship)
    ((SEARCH_RADIUS_KM - distance_km) / SEARCH_RADIUS_KM) * 100
  end

  def send_driver_offers(ranked_drivers)
    assignments = []

    ranked_drivers.each do |ranked_driver|
      driver = ranked_driver[:driver]
      location = driver.current_location

      assignment = DriverAssignment.create!(
        ride: @ride,
        driver: driver,
        distance_to_pickup: location.distance_to(@pickup_lat, @pickup_lng),
        eta_to_pickup: calculate_eta(location)
      )

      # Increment driver's total trips count
      driver.increment!(:total_trips)

      # Send push notification to driver
      NotificationService.call(
        user: driver.user,
        type: 'ride_offer',
        title: 'New Ride Request',
        body: "Pickup in #{assignment.distance_to_pickup.round(1)} km",
        data: { ride_id: @ride.id, assignment_id: assignment.id }
      )

      assignments << assignment
    end

    # Schedule timeout job
    MatchingTimeoutJob.set(wait: MATCHING_TIMEOUT).perform_later(@ride.id)

    assignments
  end

  def calculate_eta(location)
    distance_km = location.distance_to(@pickup_lat, @pickup_lng)
    # Assume average speed of 30 km/h in city traffic
    (distance_km / 30.0 * 60).round(0) # in minutes
  end
end


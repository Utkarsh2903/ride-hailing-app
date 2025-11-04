class DriverMatchingJob < ApplicationJob
  queue_as :critical

  # Retry strategy for matching failures
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(ride_id)
    ride = Ride.find(ride_id)
    
    # Only match if ride is still in matchable state
    return unless ride.requested? || ride.searching?

    result = DriverMatchingService.call(ride)

    if result.failure?
      # If no drivers found, mark ride as failed and notify rider
      ride.fail!
      
      NotificationService.call(
        user: ride.rider.user,
        type: 'no_drivers_available',
        title: 'No Drivers Available',
        body: 'Sorry, no drivers are available nearby. Please try again.',
        data: { ride_id: ride.id }
      )
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Driver matching failed - Ride not found: #{e.message}"
  end
end


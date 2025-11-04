class MatchingTimeoutJob < ApplicationJob
  queue_as :default

  def perform(ride_id)
    ride = Ride.find(ride_id)
    
    # If ride is still searching after timeout, mark as failed
    if ride.searching?
      ride.fail!
      
      # Notify rider
      NotificationService.call(
        user: ride.rider.user,
        type: 'matching_timeout',
        title: 'No Driver Found',
        body: 'We could not find a driver for your ride. Please try again.',
        data: { ride_id: ride.id }
      )

      # Update rider stats
      ride.rider.increment!(:cancelled_trips)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Matching timeout failed - Ride not found: #{e.message}"
  end
end


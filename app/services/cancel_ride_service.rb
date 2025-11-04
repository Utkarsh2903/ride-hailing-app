# Service for cancelling rides
# Handles business logic, notifications, and stats updates
class CancelRideService < ApplicationService
  def initialize(ride:, user:, reason: nil)
    @ride = ride
    @user = user
    @reason = reason
  end

  def call
    return failure('Ride cannot be cancelled') unless @ride.can_be_cancelled?

    ActiveRecord::Base.transaction do
      cancel_ride!
      update_user_stats!
      send_notification!
    end

    success(ride: @ride)
  rescue StandardError => e
    Rails.logger.error("Cancel ride failed for ride #{@ride.id}: #{e.message}")
    failure("Cancellation failed: #{e.message}")
  end

  private

  def cancel_ride!
    @ride.update!(
      cancelled_by: @user.role,
      cancelled_at: Time.current
    )
    @ride.cancel!
  end

  def update_user_stats!
    if @user.rider?
      @user.rider.increment!(:cancelled_trips)
    elsif @user.driver?
      @user.driver.increment!(:cancelled_trips)
      @user.driver.update_metrics!
    end
  end

  def send_notification!
    recipient = if @user.rider? && @ride.driver
                  @ride.driver.user
                elsif @user.driver? && @ride.rider
                  @ride.rider.user
                end

    return unless recipient

    NotificationService.call(
      user: recipient,
      type: 'ride_cancelled',
      title: 'Ride Cancelled',
      body: cancellation_message,
      data: { ride_id: @ride.id, reason: @reason }
    )
  end

  def cancellation_message
    if @user.rider?
      'The rider has cancelled the ride'
    elsif @user.driver?
      'The driver has cancelled the ride'
    else
      'The ride has been cancelled'
    end
  end
end


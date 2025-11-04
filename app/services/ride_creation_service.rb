# Service for creating ride requests with validation and idempotency
# Implements Transaction Script Pattern
class RideCreationService < ApplicationService
  def initialize(rider:, params:, idempotency_key: nil)
    @rider = rider
    @params = params
    @idempotency_key = idempotency_key || SecureRandom.uuid
  end

  def call
    # Check for existing ride with same idempotency key
    existing_ride = Ride.find_by(idempotency_key: @idempotency_key)
    return success(ride: existing_ride, created: false) if existing_ride

    # Check if rider already has an active ride
    if @rider.has_active_ride?
      return failure('You already have an active ride')
    end

    # Calculate surge pricing for pickup location
    surge_result = SurgePricingService.call(
      latitude: @params[:pickup_latitude],
      longitude: @params[:pickup_longitude],
      tier: @params[:tier] || 'standard'
    )

    unless surge_result.success?
      return failure('Failed to calculate surge pricing')
    end

    # Create the ride
    ride = nil
    ActiveRecord::Base.transaction do
      ride = @rider.rides.create!(
        pickup_latitude: @params[:pickup_latitude],
        pickup_longitude: @params[:pickup_longitude],
        pickup_address: @params[:pickup_address],
        dropoff_latitude: @params[:dropoff_latitude],
        dropoff_longitude: @params[:dropoff_longitude],
        dropoff_address: @params[:dropoff_address],
        tier: @params[:tier] || 'standard',
        payment_method: @params[:payment_method] || @rider.preferred_payment_method,
        surge_multiplier: surge_result.data[:surge_multiplier],
        idempotency_key: @idempotency_key,
        metadata: {
          surge_zone: surge_result.data[:zone_name],
          surge_message: surge_result.data[:message]
        }
      )

      # Update rider stats
      @rider.increment!(:total_trips)
    end

    # Start driver matching asynchronously
    DriverMatchingJob.perform_later(ride.id)

    # Send confirmation notification
    NotificationService.call(
      user: @rider.user,
      type: 'ride_requested',
      title: 'Ride Requested',
      body: 'Finding drivers nearby...',
      data: { ride_id: ride.id }
    )

    success(ride: ride, created: true, surge_info: surge_result.data)
  rescue ActiveRecord::RecordInvalid => e
    failure(e.record.errors.full_messages)
  rescue StandardError => e
    failure("Ride creation failed: #{e.message}")
  end
end


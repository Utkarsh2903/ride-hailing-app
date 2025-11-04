# Service for completing trips and triggering payments
# Implements Transaction Script Pattern with proper error handling
class TripCompletionService < ApplicationService
  def initialize(trip:, actual_distance: nil, actual_duration: nil, route_coordinates: [])
    @trip = trip
    @ride = trip.ride
    @actual_distance = actual_distance
    @actual_duration = actual_duration
    @route_coordinates = route_coordinates
  end

  def call
    return failure('Trip not in correct state') unless @trip.in_progress? || @trip.paused?

    ActiveRecord::Base.transaction do
      # Update trip data
      @trip.update!(
        actual_distance: @actual_distance || calculate_actual_distance,
        actual_duration: @actual_duration || calculate_actual_duration,
        route_coordinates: @route_coordinates
      )

      # Complete the trip (this triggers fare calculation)
      @trip.complete!

      # Update ride status
      @ride.complete! if @ride.may_complete?

      # Update driver and rider stats
      update_participant_stats

      # Create payment record
      payment = create_payment

      # Process payment asynchronously
      PaymentProcessingJob.perform_later(payment.id)

      # Send notifications
      send_completion_notifications

      success(
        trip: @trip,
        ride: @ride,
        payment: payment,
        fare_breakdown: fare_breakdown
      )
    end
  rescue StandardError => e
    failure("Trip completion failed: #{e.message}")
  end

  private

  def calculate_actual_distance
    # If we have route coordinates, calculate from them
    if @route_coordinates.present? && @route_coordinates.is_a?(Array)
      calculate_route_distance(@route_coordinates)
    else
      # Fallback to estimated distance
      @ride.estimated_distance
    end
  end

  def calculate_route_distance(coordinates)
    return 0 if coordinates.length < 2

    total_distance = 0
    coordinates.each_cons(2) do |point1, point2|
      total_distance += haversine_distance(
        point1['lat'] || point1[:lat],
        point1['lng'] || point1[:lng],
        point2['lat'] || point2[:lat],
        point2['lng'] || point2[:lng]
      )
    end

    total_distance.round(2)
  end

  def haversine_distance(lat1, lon1, lat2, lon2)
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

  def calculate_actual_duration
    return 0 unless @trip.started_at

    ended_at = @trip.ended_at || Time.current
    ((ended_at - @trip.started_at) / 60.0).round(0)
  end

  def fare_breakdown
    {
      base_fare: @trip.base_fare,
      distance_fare: @trip.distance_fare,
      time_fare: @trip.time_fare,
      surge_amount: @trip.surge_amount,
      waiting_charge: @trip.waiting_charge,
      service_fee: @trip.service_fee,
      tax_amount: @trip.tax_amount,
      discount_amount: @trip.discount_amount,
      tip_amount: @trip.tip_amount,
      total_fare: @trip.total_fare
    }
  end

  def update_participant_stats
    driver = @ride.driver
    rider = @ride.rider

    driver.increment!(:completed_trips)
    rider.increment!(:completed_trips)
  end

  def create_payment
    Payment.create!(
      ride: @ride,
      rider: @ride.rider,
      driver: @ride.driver,
      amount: @trip.total_fare,
      payment_method: @ride.payment_method,
      currency: 'USD',
      tax_amount: @trip.tax_amount
    )
  end

  def send_completion_notifications
    # Notify rider
    NotificationService.call(
      user: @ride.rider.user,
      type: 'trip_completed',
      title: 'Trip Completed',
      body: "Total fare: $#{@trip.total_fare}",
      data: { 
        ride_id: @ride.id,
        trip_id: @trip.id,
        fare: @trip.total_fare
      }
    )

    # Notify driver
    NotificationService.call(
      user: @ride.driver.user,
      type: 'trip_completed',
      title: 'Trip Completed',
      body: "You earned $#{@trip.total_fare * 0.8}",
      data: { 
        ride_id: @ride.id,
        trip_id: @trip.id,
        earnings: (@trip.total_fare * 0.8).round(2)
      }
    )
  end
end


# Serializer for Ride responses
# Follows Single Responsibility Principle
class RideSerializer
  include JSONAPI::Serializer

  attributes :status, :tier, :payment_method, :payment_status,
             :estimated_fare, :surge_multiplier, :estimated_distance, :estimated_duration

  attribute :pickup do |ride|
    {
      latitude: ride.pickup_latitude.to_f,
      longitude: ride.pickup_longitude.to_f,
      address: ride.pickup_address
    }
  end

  attribute :dropoff do |ride|
    {
      latitude: ride.dropoff_latitude.to_f,
      longitude: ride.dropoff_longitude.to_f,
      address: ride.dropoff_address
    }
  end

  attribute :timestamps do |ride|
    {
      requested_at: ride.requested_at&.iso8601,
      accepted_at: ride.accepted_at&.iso8601,
      started_at: ride.started_at&.iso8601,
      completed_at: ride.completed_at&.iso8601,
      cancelled_at: ride.cancelled_at&.iso8601
    }
  end

  attribute :driver, if: Proc.new { |ride| ride.driver.present? } do |ride|
    DriverSerializer.new(ride.driver).serializable_hash[:data][:attributes]
  end

  attribute :rider do |ride|
    RiderSerializer.new(ride.rider).serializable_hash[:data][:attributes]
  end
end


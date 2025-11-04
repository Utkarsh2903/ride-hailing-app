# Serializer for Trip responses
class TripSerializer
  include JSONAPI::Serializer

  attributes :status, :actual_distance, :actual_duration, :total_fare

  attribute :timestamps do |trip|
    {
      started_at: trip.started_at&.iso8601,
      ended_at: trip.ended_at&.iso8601
    }
  end

  attribute :fare_breakdown do |trip|
    {
      base_fare: trip.base_fare,
      distance_fare: trip.distance_fare,
      time_fare: trip.time_fare,
      surge_amount: trip.surge_amount,
      waiting_charge: trip.waiting_charge,
      service_fee: trip.service_fee,
      tax_amount: trip.tax_amount,
      tip_amount: trip.tip_amount
    }
  end
end


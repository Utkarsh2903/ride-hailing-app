module Api
  module V1
    class TripsController < BaseController
      # GET /api/v1/trips/:id
      def show
        trip = Trip.find(params[:id])
        authorize trip

        render_success(trip: TripSerializer.new(trip).serializable_hash[:data][:attributes])
      end

      # POST /api/v1/trips/:id/end
      def end_trip
        trip = Trip.find(params[:id])
        authorize trip, :end_trip?

        # Validate request parameters
        validator = TripEndParams.from_params(trip_end_params)
        unless validator.valid?
          return render_error(validator.errors.full_messages, status: :unprocessable_entity)
        end

        result = TripCompletionService.call(
          trip: trip,
          actual_distance: validator.to_h[:actual_distance],
          actual_duration: validator.to_h[:actual_duration]
        )

        if result.success?
          render_success(
            trip: TripSerializer.new(result.data[:trip]).serializable_hash[:data][:attributes],
            payment: result.data[:payment] ? PaymentSerializer.new(result.data[:payment]).serializable_hash[:data][:attributes] : nil
          )
        else
          render_error(result.error_messages, status: :unprocessable_entity)
        end
      end

      private

      def trip_end_params
        params.permit(:actual_distance, :actual_duration)
      end
    end
  end
end

module Api
  module V1
    class RidesController < BaseController
      # POST /api/v1/rides
      def create
        return render_error('Rider profile required', status: :forbidden) unless current_rider

        # Validate request parameters
        validator = RideCreateParams.from_params(ride_params)
        unless validator.valid?
          return render_error(validator.errors.full_messages, status: :unprocessable_entity)
        end

        result = RideCreationService.call(
          rider: current_rider,
          params: validator.to_h,
          idempotency_key: idempotency_key
        )

        if result.success?
          render_success(
            {
              ride: RideSerializer.new(result.data[:ride]).serializable_hash[:data][:attributes],
              surge_info: result.data[:surge_info],
              created: result.data[:created]
            },
            status: result.data[:created] ? :created : :ok
          )
        else
          render_error(result.error_messages, status: :unprocessable_entity)
        end
      end

      # GET /api/v1/rides/:id
      def show
        ride = find_ride
        authorize ride

        render_success(ride: RideSerializer.new(ride).serializable_hash[:data][:attributes])
      end

      # GET /api/v1/rides
      def index
        rides = policy_scope(Ride)
                  .includes(:rider, :driver, :trip, :payment)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(params[:per_page] || 20)

        render_success(
          rides: rides.map { |r| RideSerializer.new(r).serializable_hash[:data][:attributes] },
          meta: pagination_meta(rides)
        )
      end

      # POST /api/v1/rides/:id/cancel
      def cancel
        ride = find_ride
        authorize ride

        result = CancelRideService.call(
          ride: ride,
          user: current_user,
          reason: params[:reason]
        )

        if result.success?
          render_success(ride: RideSerializer.new(result.data[:ride]).serializable_hash[:data][:attributes])
        else
          render_error(result.error, status: :unprocessable_entity)
        end
      end

      # GET /api/v1/rides/:id/track
      def track
        ride = find_ride
        authorize ride, :track?

        driver_location = if ride.driver&.current_location
          DriverLocationSerializer.new(ride.driver.current_location).serializable_hash[:data][:attributes]
        end

        eta = if ride.driver
          EtaCalculator.call(ride.driver, ride.pickup_latitude, ride.pickup_longitude)
        end

        render_success(
          ride: RideSerializer.new(ride).serializable_hash[:data][:attributes],
          driver_location: driver_location,
          eta: eta
        )
      end

      private

      def ride_params
        params.require(:ride).permit(
          :pickup_latitude, :pickup_longitude, :pickup_address,
          :dropoff_latitude, :dropoff_longitude, :dropoff_address,
          :tier, :payment_method
        )
      end

      def find_ride
        Ride.find(params[:id])
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end

module Api
  module V1
    class DriversController < BaseController
      before_action :set_driver
      before_action -> { authorize @driver }, except: [:index]

      # POST /api/v1/drivers/:id/location
      def update_location
        # Validate request parameters
        validator = LocationUpdateParams.from_params(location_params)
        unless validator.valid?
          return render_error(validator.errors.full_messages, status: :unprocessable_entity)
        end

        location_data = validator.to_h

        success = update_driver_location_cache(location_data)
        return render_error('Update rate limit exceeded (max 2/second)', status: :too_many_requests) unless success

        update_activity_async

        render_success(message: 'Location updated', timestamp: Time.current.to_f)
      end
      
      # POST /api/v1/drivers/:id/location/batch
      def batch_update_location
        locations = params.require(:locations)
        
        return render_error('Too many locations in batch (max 100)', status: :unprocessable_entity) if locations.count > 100
        
        successful = 0
        locations.each do |loc|
          validator = LocationUpdateParams.from_params(loc)
          next unless validator.valid?

          if DriverLocationCache.update_location(
            driver_id: current_driver.id,
            latitude: validator.to_h[:latitude],
            longitude: validator.to_h[:longitude],
            bearing: validator.to_h[:bearing],
            speed: validator.to_h[:speed],
            accuracy: validator.to_h[:accuracy],
            tenant_id: current_tenant.id
          )
            successful += 1
          end
        end
        
        render_success(
          message: "#{successful}/#{locations.count} locations updated",
          timestamp: Time.current.to_f
        )
      end

      # POST /api/v1/drivers/:id/accept
      def accept_ride
        assignment = DriverAssignment.find(params[:assignment_id])
        
        raise AuthorizationError.new('Not authorized') unless assignment.driver_id == current_driver.id
        raise BusinessLogicError.new('Assignment not available') unless assignment.offered?

        ActiveRecord::Base.transaction do
          assignment.accept!
          current_driver.increment!(:accepted_trips)
          current_driver.update_metrics!

          ride = assignment.ride
          NotificationService.call(
            user: ride.rider.user,
            type: 'driver_assigned',
            title: 'Driver Found!',
            body: "#{current_driver.user.full_name} is on the way",
            data: {
              ride_id: ride.id,
              driver: DriverSerializer.new(current_driver).serializable_hash[:data][:attributes],
              eta: EtaCalculator.call(current_driver, ride.pickup_latitude, ride.pickup_longitude)
            }
          )
        end

        render_success(
          message: 'Ride accepted',
          assignment: serialize_assignment(assignment)
        )
      end

      # POST /api/v1/drivers/:id/decline
      def decline_ride
        assignment = DriverAssignment.find(params[:assignment_id])
        
        raise AuthorizationError.new('Not authorized') unless assignment.driver_id == current_driver.id
        raise BusinessLogicError.new('Assignment not available') unless assignment.offered?

        assignment.decline_reason = params[:reason]
        assignment.decline!

        DriverMatchingJob.perform_later(assignment.ride_id)

        render_success(message: 'Ride declined')
      end

      # POST /api/v1/drivers/:id/arrive
      def mark_arrived
        ride = find_driver_ride
        raise BusinessLogicError.new('Ride not in accepted state') unless ride.accepted?

        ride.mark_driver_arrived!

        NotificationService.call(
          user: ride.rider.user,
          type: 'driver_arrived',
          title: 'Driver Arrived',
          body: 'Your driver has arrived at pickup location',
          data: { ride_id: ride.id }
        )

        render_success(ride: serialize_ride(ride))
      end

      # POST /api/v1/drivers/:id/start_trip
      def start_trip
        ride = find_driver_ride
        raise BusinessLogicError.new('Driver must arrive first') unless ride.driver_arrived?

        ActiveRecord::Base.transaction do
          ride.start!
          trip = ride.create_trip!

          NotificationService.call(
            user: ride.rider.user,
            type: 'trip_started',
            title: 'Trip Started',
            body: 'Your ride has begun',
            data: { ride_id: ride.id, trip_id: trip.id }
          )
        end

        render_success(
          ride: serialize_ride(ride),
          trip: serialize_trip(ride.trip)
        )
      end

      # POST /api/v1/drivers/:id/online
      def go_online
        current_driver.go_online!
        
        render_success(
          message: 'You are now online',
          driver: serialize_driver_status(current_driver)
        )
      end

      # POST /api/v1/drivers/:id/offline
      def go_offline
        DriverLocationCache.remove_driver(current_driver.id)
        current_driver.go_offline!

        render_success(
          message: 'You are now offline',
          driver: serialize_driver_status(current_driver)
        )
      end

      # GET /api/v1/drivers/:id/earnings
      def earnings
        start_date = params[:start_date]&.to_date || 7.days.ago.to_date
        end_date = params[:end_date]&.to_date || Date.current

        payments = Payment.completed
                         .where(driver_id: current_driver.id)
                         .where(created_at: start_date.beginning_of_day..end_date.end_of_day)

        total_earnings = payments.sum(:driver_amount)
        total_trips = payments.count

        render_success(
          earnings: {
            total: total_earnings.round(2),
            trips: total_trips,
            average_per_trip: total_trips.positive? ? (total_earnings / total_trips).round(2) : 0,
            period: { start_date: start_date, end_date: end_date }
          }
        )
      end

      private

      def set_driver
        @driver = current_driver || Driver.find_by(id: params[:id])
      end

      def location_params
        params.require(:location).permit(:latitude, :longitude, :bearing, :speed, :accuracy, :altitude)
      end


      def update_driver_location_cache(location_data)
        DriverLocationCache.update_location(
          driver_id: current_driver.id,
          latitude: location_data[:latitude],
          longitude: location_data[:longitude],
          bearing: location_data[:bearing],
          speed: location_data[:speed],
          accuracy: location_data[:accuracy],
          tenant_id: current_tenant.id
        )
      end

      def update_activity_async
        UpdateDriverActivityJob.perform_later(current_driver.id) if rand < 0.1
      end

      def find_driver_ride
        ride = Ride.find(params[:ride_id])
        raise Pundit::NotAuthorizedError, 'Not authorized' unless ride.driver_id == current_driver.id
        ride
      end

      def serialize_assignment(assignment)
        DriverAssignmentSerializer.new(assignment, include: [:ride])
                                  .serializable_hash[:data][:attributes]
      end

      def serialize_ride(ride)
        RideSerializer.new(ride).serializable_hash[:data][:attributes]
      end

      def serialize_trip(trip)
        TripSerializer.new(trip).serializable_hash[:data][:attributes]
      end

      def serialize_driver_status(driver)
        {
          id: driver.id,
          status: driver.status,
          rating: driver.rating,
          total_trips: driver.total_trips,
          completed_trips: driver.completed_trips,
          acceptance_rate: driver.acceptance_rate
        }
      end
    end
  end
end

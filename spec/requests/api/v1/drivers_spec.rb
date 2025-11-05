require 'swagger_helper'

RSpec.describe 'api/v1/drivers', type: :request do
  path '/api/v1/drivers/{id}/location' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Update driver location') do
      tags 'Drivers'
      description 'Send driver location update (1-2 updates per second)'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :location, in: :body, schema: {
        type: :object,
        properties: {
          latitude: { type: :number, format: :float, example: 12.9716 },
          longitude: { type: :number, format: :float, example: 77.5946 },
          bearing: { type: :number, format: :float, example: 45.5, description: 'Direction in degrees' },
          speed: { type: :number, format: :float, example: 30.5, description: 'Speed in km/h' },
          accuracy: { type: :number, format: :float, example: 10.0, description: 'GPS accuracy in meters' }
        },
        required: ['latitude', 'longitude']
      }

      response(200, 'Location updated') do
        run_test!
      end

      response(403, 'Not a driver') do
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/accept' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Accept ride assignment') do
      tags 'Drivers'
      description 'Accept a ride assignment'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          ride_id: { type: :string, format: :uuid, description: 'Ride ID to accept' }
        },
        required: ['ride_id']
      }

      response(200, 'Ride accepted') do
        schema type: :object,
          properties: {
            ride: { type: :object },
            message: { type: :string }
          }
        run_test!
      end

      response(422, 'Cannot accept ride') do
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/decline' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Decline ride assignment') do
      tags 'Drivers'
      description 'Decline a ride assignment'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          ride_id: { type: :string, format: :uuid },
          reason: { type: :string, example: 'Too far' }
        },
        required: ['ride_id']
      }

      response(200, 'Ride declined') do
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/arrive' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Mark arrived at pickup') do
      tags 'Drivers'
      description 'Notify that driver has arrived at pickup location'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :arrival, in: :body, schema: {
        type: :object,
        properties: {
          ride_id: { type: :string, format: :uuid }
        },
        required: ['ride_id']
      }

      response(200, 'Marked as arrived') do
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/start_trip' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Start trip') do
      tags 'Drivers'
      description 'Start the trip after rider gets in'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :trip, in: :body, schema: {
        type: :object,
        properties: {
          ride_id: { type: :string, format: :uuid }
        },
        required: ['ride_id']
      }

      response(200, 'Trip started') do
        schema type: :object,
          properties: {
            trip: { type: :object },
            message: { type: :string }
          }
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/online' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Go online') do
      tags 'Drivers'
      description 'Set driver status to online and available for rides'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'Driver is now online') do
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/offline' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    post('Go offline') do
      tags 'Drivers'
      description 'Set driver status to offline'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'Driver is now offline') do
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/earnings' do
    parameter name: 'id', in: :path, type: :string, description: 'Driver ID'

    get('Get earnings') do
      tags 'Drivers'
      description 'Get driver earnings summary'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false

      response(200, 'successful') do
        schema type: :object,
          properties: {
            earnings: {
              type: :object,
              properties: {
                total: { type: :number },
                completed_trips: { type: :integer },
                average_per_trip: { type: :number }
              }
            }
          }
        run_test!
      end
    end
  end
end


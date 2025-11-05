require 'swagger_helper'

RSpec.describe 'api/v1/trips', type: :request do
  path '/api/v1/trips/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Trip ID'

    get('Get trip details') do
      tags 'Trips'
      description 'Get details of a specific trip'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'successful') do
        schema type: :object,
          properties: {
            trip: {
              type: :object,
              properties: {
                id: { type: :string },
                ride_id: { type: :string },
                status: { type: :string },
                started_at: { type: :string, format: 'date-time' },
                ended_at: { type: :string, format: 'date-time' },
                actual_distance: { type: :number },
                actual_duration: { type: :integer },
                total_fare: { type: :number },
                fare_breakdown: {
                  type: :object,
                  properties: {
                    base_fare: { type: :number },
                    distance_fare: { type: :number },
                    time_fare: { type: :number },
                    surge_amount: { type: :number }
                  }
                }
              }
            }
          }
        run_test!
      end

      response(404, 'Trip not found') do
        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/end' do
    parameter name: 'id', in: :path, type: :string, description: 'Trip ID'

    post('End trip') do
      tags 'Trips'
      description 'End the trip and calculate final fare'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :trip_end, in: :body, schema: {
        type: :object,
        properties: {
          final_latitude: { type: :number, format: :float, description: 'Final dropoff latitude' },
          final_longitude: { type: :number, format: :float, description: 'Final dropoff longitude' }
        }
      }

      response(200, 'Trip ended successfully') do
        schema type: :object,
          properties: {
            trip: { type: :object },
            payment: { type: :object },
            message: { type: :string }
          }
        run_test!
      end

      response(422, 'Cannot end trip') do
        run_test!
      end
    end
  end
end


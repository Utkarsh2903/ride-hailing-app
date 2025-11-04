require 'swagger_helper'

RSpec.describe 'Drivers API', type: :request do
  path '/api/v1/drivers/{id}/location' do
    parameter name: :id, in: :path, type: :integer, description: 'Driver ID', required: true

    post 'Update driver location' do
      tags 'Drivers'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Update driver GPS location. High-frequency endpoint (1-2 updates per second). ' \
                  'Validates location accuracy and rate limits. Updates Redis cache for fast driver matching.'
      
      parameter name: :location, in: :body, schema: {
        type: :object,
        required: ['latitude', 'longitude'],
        properties: {
          latitude: { 
            type: :number,
            format: :double,
            minimum: -90,
            maximum: 90,
            example: 40.7128,
            description: 'Current latitude (-90 to 90 degrees)'
          },
          longitude: { 
            type: :number,
            format: :double,
            minimum: -180,
            maximum: 180,
            example: -74.0060,
            description: 'Current longitude (-180 to 180 degrees)'
          },
          bearing: { 
            type: :number,
            minimum: 0,
            maximum: 360,
            example: 45.5,
            description: 'Direction of travel in degrees (0-360)'
          },
          speed: { 
            type: :number,
            minimum: 0,
            maximum: 200,
            example: 35.5,
            description: 'Current speed in km/h (0-200)'
          },
          accuracy: { 
            type: :number,
            minimum: 0,
            maximum: 100,
            example: 10.5,
            description: 'GPS accuracy in meters (0-100, lower is better)'
          },
          altitude: { 
            type: :number,
            minimum: -500,
            maximum: 9000,
            example: 100.0,
            description: 'Altitude in meters (-500 to 9000)'
          }
        }
      }

      response '200', 'location updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Location updated' },
                 timestamp: { type: :number, format: :double, example: 1704283200.123 }
               }
        
        let(:id) { 1 }
        let(:location) do
          {
            latitude: 40.7128,
            longitude: -74.0060,
            bearing: 45.5,
            speed: 35.5,
            accuracy: 10.5
          }
        end
        
        run_test!
      end

      response '422', 'invalid location data' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          invalid_range: {
            value: {
              success: false,
              error: ['Latitude must be between -90 and 90 degrees']
            }
          },
          low_accuracy: {
            value: {
              success: false,
              error: ['Accuracy must be between 0 and 100 meters']
            }
          }
        }
        
        let(:id) { 1 }
        let(:location) { { latitude: 999, longitude: -74.0060 } }
        
        run_test!
      end

      response '429', 'rate limit exceeded' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          rate_limit: {
            value: {
              success: false,
              error: 'Update rate limit exceeded (max 2/second)'
            }
          }
        }
        
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/accept' do
    parameter name: :id, in: :path, type: :integer, description: 'Driver ID', required: true

    post 'Accept a ride assignment' do
      tags 'Drivers'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Accept an offered ride assignment. Updates ride status, notifies rider, and broadcasts via WebSocket.'
      
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        required: ['assignment_id'],
        properties: {
          assignment_id: { 
            type: :integer,
            example: 1,
            description: 'ID of the driver assignment to accept'
          }
        }
      }

      response '200', 'ride accepted' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Ride accepted' },
                 assignment: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     status: { type: :string, example: 'accepted' },
                     ride: { '$ref' => '#/components/schemas/Ride' }
                   }
                 }
               }
        
        let(:id) { 1 }
        let(:assignment) { { assignment_id: 1 } }
        
        run_test!
      end

      response '422', 'cannot accept' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          not_available: {
            value: {
              success: false,
              error: 'Assignment not available'
            }
          },
          not_authorized: {
            value: {
              success: false,
              error: 'Not authorized'
            }
          }
        }
        
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/online' do
    parameter name: :id, in: :path, type: :integer, description: 'Driver ID', required: true

    post 'Go online' do
      tags 'Drivers'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Set driver status to online and start receiving ride requests.'

      response '200', 'now online' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'You are now online' },
                 driver: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     status: { type: :string, example: 'online' },
                     rating: { type: :number, example: 4.8 },
                     total_trips: { type: :integer, example: 150 },
                     completed_trips: { type: :integer, example: 148 },
                     acceptance_rate: { type: :number, example: 95.5 }
                   }
                 }
               }
        
        let(:id) { 1 }
        
        run_test!
      end
    end
  end

  path '/api/v1/drivers/{id}/earnings' do
    parameter name: :id, in: :path, type: :integer, description: 'Driver ID', required: true

    get 'Get earnings report' do
      tags 'Drivers'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Get driver earnings for a specific date range. Defaults to last 7 days.'
      
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false, 
                description: 'Start date (YYYY-MM-DD)', example: '2025-01-01'
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false,
                description: 'End date (YYYY-MM-DD)', example: '2025-01-07'

      response '200', 'earnings data' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 earnings: {
                   type: :object,
                   properties: {
                     total: { type: :number, format: :float, example: 450.75, description: 'Total earnings in the period' },
                     trips: { type: :integer, example: 25, description: 'Number of completed trips' },
                     average_per_trip: { type: :number, format: :float, example: 18.03, description: 'Average earning per trip' },
                     period: {
                       type: :object,
                       properties: {
                         start_date: { type: :string, format: :date, example: '2025-01-01' },
                         end_date: { type: :string, format: :date, example: '2025-01-07' }
                       }
                     }
                   }
                 }
               }
        
        let(:id) { 1 }
        
        run_test!
      end
    end
  end
end


require 'swagger_helper'

RSpec.describe 'Rides API', type: :request do
  path '/api/v1/rides' do
    post 'Create a ride request' do
      tags 'Rides'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Create a new ride request. Validates pickup/dropoff locations, calculates estimated fare with surge pricing, and initiates driver matching.'
      
      parameter name: :ride, in: :body, schema: {
        type: :object,
        required: ['pickup_latitude', 'pickup_longitude', 'pickup_address', 'dropoff_latitude', 'dropoff_longitude', 'dropoff_address'],
        properties: {
          pickup_latitude: { 
            type: :number, 
            format: :double,
            minimum: -90, 
            maximum: 90,
            example: 40.7128,
            description: 'Pickup location latitude (-90 to 90 degrees)'
          },
          pickup_longitude: { 
            type: :number,
            format: :double,
            minimum: -180, 
            maximum: 180,
            example: -74.0060,
            description: 'Pickup location longitude (-180 to 180 degrees)'
          },
          pickup_address: { 
            type: :string,
            minLength: 5,
            maxLength: 255,
            example: '123 Main St, New York, NY 10001',
            description: 'Pickup address (5-255 characters)'
          },
          dropoff_latitude: { 
            type: :number,
            format: :double,
            minimum: -90, 
            maximum: 90,
            example: 40.7589,
            description: 'Dropoff location latitude (-90 to 90 degrees)'
          },
          dropoff_longitude: { 
            type: :number,
            format: :double,
            minimum: -180, 
            maximum: 180,
            example: -73.9851,
            description: 'Dropoff location longitude (-180 to 180 degrees)'
          },
          dropoff_address: { 
            type: :string,
            minLength: 5,
            maxLength: 255,
            example: '456 Park Ave, New York, NY 10022',
            description: 'Dropoff address (5-255 characters)'
          },
          tier: { 
            type: :string,
            enum: ['economy', 'standard', 'premium', 'suv', 'luxury'],
            default: 'standard',
            example: 'standard',
            description: 'Vehicle tier selection'
          },
          payment_method: { 
            type: :string,
            enum: ['card', 'cash', 'wallet'],
            default: 'card',
            example: 'card',
            description: 'Payment method for the ride'
          }
        }
      }

      response '201', 'ride created' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 ride: { '$ref' => '#/components/schemas/Ride' },
                 surge_info: {
                   type: :object,
                   properties: {
                     surge_multiplier: { type: :number, example: 1.5 },
                     zone_name: { type: :string, example: 'downtown' },
                     surge_active: { type: :boolean, example: true },
                     message: { type: :string, example: 'High demand - fares are higher' }
                   }
                 },
                 created: { type: :boolean, example: true }
               },
               required: ['success', 'ride']
        
        let(:ride) do
          {
            pickup_latitude: 40.7128,
            pickup_longitude: -74.0060,
            pickup_address: '123 Main St, New York, NY 10001',
            dropoff_latitude: 40.7589,
            dropoff_longitude: -73.9851,
            dropoff_address: '456 Park Ave, New York, NY 10022',
            tier: 'standard',
            payment_method: 'card'
          }
        end
        
        run_test!
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          missing_fields: {
            value: {
              success: false,
              error: ['Pickup latitude is required', 'Pickup longitude is required']
            }
          },
          invalid_range: {
            value: {
              success: false,
              error: ['Pickup latitude must be between -90 and 90 degrees']
            }
          },
          same_location: {
            value: {
              success: false,
              error: ['Pickup and dropoff locations must be different']
            }
          }
        }
        
        let(:ride) { { pickup_latitude: 'invalid' } }
        
        run_test!
      end

      response '403', 'not a rider' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          not_rider: {
            value: {
              success: false,
              error: 'Rider profile required'
            }
          }
        }
        
        run_test!
      end
    end

    get 'List rides' do
      tags 'Rides'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Get list of rides for current user (rider or driver). Supports pagination.'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number (default: 1)', example: 1
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page (default: 20, max: 100)', example: 20

      response '200', 'rides listed' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 rides: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Ride' }
                 },
                 meta: { '$ref' => '#/components/schemas/Pagination' }
               }
        
        run_test!
      end
    end
  end

  path '/api/v1/rides/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Ride ID', required: true

    get 'Get ride details' do
      tags 'Rides'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Get detailed information about a specific ride including trip and payment details if available.'

      response '200', 'ride found' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 ride: { '$ref' => '#/components/schemas/Ride' }
               }
        
        let(:id) { 1 }
        
        run_test!
      end

      response '404', 'ride not found' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:id) { 99999 }
        
        run_test!
      end

      response '403', 'not authorized' do
        schema '$ref' => '#/components/schemas/Error'
        
        run_test!
      end
    end
  end

  path '/api/v1/rides/{id}/cancel' do
    parameter name: :id, in: :path, type: :integer, description: 'Ride ID', required: true

    post 'Cancel a ride' do
      tags 'Rides'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Cancel a ride request. Only possible for rides in requested, searching, accepted, or driver_arrived status.'
      
      parameter name: :cancellation, in: :body, schema: {
        type: :object,
        properties: {
          reason: { 
            type: :string,
            example: 'Found alternative transportation',
            description: 'Optional cancellation reason'
          }
        }
      }

      response '200', 'ride cancelled' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 ride: { '$ref' => '#/components/schemas/Ride' }
               }
        
        let(:id) { 1 }
        let(:cancellation) { { reason: 'Changed plans' } }
        
        run_test!
      end

      response '422', 'cannot cancel' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          already_in_progress: {
            value: {
              success: false,
              error: 'Ride cannot be cancelled'
            }
          }
        }
        
        let(:id) { 1 }
        
        run_test!
      end
    end
  end

  path '/api/v1/rides/{id}/track' do
    parameter name: :id, in: :path, type: :integer, description: 'Ride ID', required: true

    get 'Track ride in real-time' do
      tags 'Rides'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Get real-time tracking information including driver location and ETA. Only available for accepted or in-progress rides.'

      response '200', 'tracking data' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 ride: { '$ref' => '#/components/schemas/Ride' },
                 driver_location: {
                   type: :object,
                   properties: {
                     latitude: { type: :number, example: 40.7500 },
                     longitude: { type: :number, example: -73.9900 },
                     bearing: { type: :number, example: 45.5 },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 },
                 eta: {
                   type: :object,
                   properties: {
                     distance_km: { type: :number, example: 2.3 },
                     eta_minutes: { type: :integer, example: 5 },
                     estimated_arrival: { type: :string, format: 'date-time' }
                   }
                 }
               }
        
        let(:id) { 1 }
        
        run_test!
      end

      response '422', 'not trackable' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:id) { 1 }
        
        run_test!
      end
    end
  end
end

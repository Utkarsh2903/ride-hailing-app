require 'swagger_helper'

RSpec.describe 'api/v1/rides', type: :request do
  path '/api/v1/rides' do
    post('Create ride request') do
      tags 'Rides'
      description 'Create a new ride request as a rider'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: 'Idempotency-Key', in: :header, type: :string, required: false, description: 'Optional key to prevent duplicate requests'
      parameter name: :ride, in: :body, schema: {
        type: :object,
        properties: {
          pickup_latitude: { type: :number, format: :float, example: 12.9716 },
          pickup_longitude: { type: :number, format: :float, example: 77.5946 },
          pickup_address: { type: :string, example: '123 Main St' },
          dropoff_latitude: { type: :number, format: :float, example: 12.9141 },
          dropoff_longitude: { type: :number, format: :float, example: 77.6412 },
          dropoff_address: { type: :string, example: '456 Park Ave' },
          tier: { type: :string, enum: ['economy', 'standard', 'premium', 'suv', 'luxury'], example: 'standard' },
          payment_method: { type: :string, enum: ['card', 'cash', 'wallet'], example: 'card' }
        },
        required: ['pickup_latitude', 'pickup_longitude', 'dropoff_latitude', 'dropoff_longitude']
      }

      response(201, 'Ride created successfully') do
        schema type: :object,
          properties: {
            ride: {
              type: :object,
              properties: {
                id: { type: :string },
                status: { type: :string },
                tier: { type: :string },
                estimated_fare: { type: :number },
                estimated_distance: { type: :number },
                surge_multiplier: { type: :number }
              }
            }
          }
        run_test!
      end

      response(422, 'Validation failed') do
        run_test!
      end
    end

    get('List rides') do
      tags 'Rides'
      description 'Get list of rides for current user'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            rides: { type: :array, items: { type: :object } },
            meta: {
              type: :object,
              properties: {
                total: { type: :integer },
                page: { type: :integer },
                per_page: { type: :integer }
              }
            }
          }
        run_test!
      end
    end
  end

  path '/api/v1/rides/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Ride ID'

    get('Get ride details') do
      tags 'Rides'
      description 'Get details of a specific ride'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'successful') do
        schema type: :object,
          properties: {
            ride: { type: :object }
          }
        run_test!
      end

      response(404, 'Ride not found') do
        run_test!
      end
    end
  end

  path '/api/v1/rides/{id}/cancel' do
    parameter name: 'id', in: :path, type: :string, description: 'Ride ID'

    post('Cancel ride') do
      tags 'Rides'
      description: 'Cancel a ride request'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :cancellation, in: :body, schema: {
        type: :object,
        properties: {
          reason: { type: :string, example: 'Changed my mind' }
        }
      }

      response(200, 'Ride cancelled successfully') do
        run_test!
      end

      response(422, 'Cannot cancel ride') do
        run_test!
      end
    end
  end

  path '/api/v1/rides/{id}/track' do
    parameter name: 'id', in: :path, type: :string, description: 'Ride ID'

    get('Track ride') do
      tags 'Rides'
      description 'Get real-time tracking info for a ride'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'successful') do
        schema type: :object,
          properties: {
            ride: { type: :object },
            driver_location: {
              type: :object,
              properties: {
                latitude: { type: :number },
                longitude: { type: :number },
                bearing: { type: :number },
                speed: { type: :number }
              }
            }
          }
        run_test!
      end
    end
  end
end


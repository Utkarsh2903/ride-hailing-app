require 'swagger_helper'

RSpec.describe 'Trips API', type: :request do
  path '/api/v1/trips/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Trip ID', required: true

    get 'Get trip details' do
      tags 'Trips'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Get detailed information about a specific trip including fare breakdown.'

      response '200', 'trip found' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 trip: { '$ref' => '#/components/schemas/Trip' }
               }
        
        let(:id) { 1 }
        
        run_test!
      end

      response '404', 'trip not found' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:id) { 99999 }
        
        run_test!
      end

      response '403', 'not authorized' do
        schema '$ref' => '#/components/schemas/Error'
        
        description 'Only the rider or driver associated with the trip can view it'
        
        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/end' do
    parameter name: :id, in: :path, type: :integer, description: 'Trip ID', required: true

    post 'End a trip' do
      tags 'Trips'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Complete a trip and calculate final fare. Only drivers can end trips. ' \
                  'Automatically creates payment record and sends receipt to rider.'
      
      parameter name: :trip_data, in: :body, schema: {
        type: :object,
        required: ['actual_distance', 'actual_duration'],
        properties: {
          actual_distance: { 
            type: :number,
            format: :float,
            minimum: 0,
            maximum: 1000,
            example: 5.4,
            description: 'Actual trip distance in kilometers (0-1000 km)'
          },
          actual_duration: { 
            type: :integer,
            minimum: 0,
            maximum: 1440,
            example: 18,
            description: 'Actual trip duration in minutes (0-1440 minutes / 24 hours)'
          }
        }
      }

      response '200', 'trip completed' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 trip: { '$ref' => '#/components/schemas/Trip' },
                 payment: { '$ref' => '#/components/schemas/Payment' }
               }
        
        let(:id) { 1 }
        let(:trip_data) { { actual_distance: 5.4, actual_duration: 18 } }
        
        run_test!
      end

      response '422', 'invalid trip data' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          invalid_distance: {
            value: {
              success: false,
              error: ['Actual distance must be between 0 and 1000 km']
            }
          },
          invalid_duration: {
            value: {
              success: false,
              error: ['Actual duration must be between 0 and 1440 minutes (24 hours)']
            }
          }
        }
        
        let(:id) { 1 }
        let(:trip_data) { { actual_distance: -5, actual_duration: 18 } }
        
        run_test!
      end

      response '403', 'not authorized' do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          not_driver: {
            value: {
              success: false,
              error: 'Only driver can perform this action'
            }
          }
        }
        
        run_test!
      end
    end
  end
end


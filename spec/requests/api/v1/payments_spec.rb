require 'swagger_helper'

RSpec.describe 'api/v1/payments', type: :request do
  path '/api/v1/payments' do
    post('Create payment') do
      tags 'Payments'
      description 'Initiate payment for a trip'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: 'Idempotency-Key', in: :header, type: :string, required: false
      parameter name: :payment, in: :body, schema: {
        type: :object,
        properties: {
          ride_id: { type: :string, format: :uuid },
          payment_method: { type: :string, enum: ['card', 'cash', 'wallet'], example: 'card' },
          amount: { type: :number, format: :float, example: 25.50 }
        },
        required: ['ride_id', 'payment_method', 'amount']
      }

      response(201, 'Payment created') do
        schema type: :object,
          properties: {
            payment: {
              type: :object,
              properties: {
                id: { type: :string },
                status: { type: :string },
                amount: { type: :number },
                payment_method: { type: :string },
                transaction_id: { type: :string }
              }
            }
          }
        run_test!
      end

      response(422, 'Payment failed') do
        run_test!
      end
    end

    get('List payments') do
      tags 'Payments'
      description 'Get list of payments'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, enum: ['pending', 'processing', 'completed', 'failed', 'refunded'], required: false

      response(200, 'successful') do
        schema type: :object,
          properties: {
            payments: { type: :array, items: { type: :object } },
            meta: { type: :object }
          }
        run_test!
      end
    end
  end

  path '/api/v1/payments/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Payment ID'

    get('Get payment details') do
      tags 'Payments'
      description 'Get details of a specific payment'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'successful') do
        schema type: :object,
          properties: {
            payment: { type: :object }
          }
        run_test!
      end

      response(404, 'Payment not found') do
        run_test!
      end
    end
  end

  path '/api/v1/payments/{id}/retry' do
    parameter name: 'id', in: :path, type: :string, description: 'Payment ID'

    post('Retry payment') do
      tags 'Payments'
      description 'Retry a failed payment'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'Payment retry initiated') do
        run_test!
      end

      response(422, 'Cannot retry payment') do
        run_test!
      end
    end
  end

  path '/api/v1/payments/{id}/refund' do
    parameter name: 'id', in: :path, type: :string, description: 'Payment ID'

    post('Refund payment') do
      tags 'Payments'
      description 'Issue a refund for a payment'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :refund, in: :body, schema: {
        type: :object,
        properties: {
          reason: { type: :string, example: 'Cancelled ride' },
          amount: { type: :number, format: :float, description: 'Partial refund amount (optional)' }
        }
      }

      response(200, 'Refund processed') do
        run_test!
      end

      response(422, 'Cannot refund payment') do
        run_test!
      end
    end
  end
end


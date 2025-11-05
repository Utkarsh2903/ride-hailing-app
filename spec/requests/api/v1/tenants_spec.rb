require 'swagger_helper'

RSpec.describe 'api/v1/tenants', type: :request do
  path '/api/v1/tenants' do
    get('List tenants') do
      tags 'Tenants'
      description 'Get list of all tenants (super admin only)'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, enum: ['active', 'inactive', 'suspended'], required: false

      response(200, 'successful') do
        schema type: :object,
          properties: {
            tenants: { type: :array, items: { type: :object } },
            meta: { type: :object }
          }
        run_test!
      end

      response(403, 'Forbidden') do
        run_test!
      end
    end

    post('Create tenant') do
      tags 'Tenants'
      description 'Create a new tenant (super admin only)'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :tenant, in: :body, schema: {
        type: :object,
        properties: {
          slug: { type: :string, example: 'acme-rides' },
          name: { type: :string, example: 'Acme Rides' },
          subdomain: { type: :string, example: 'acme' },
          region: { type: :string, example: 'us-east' },
          country_code: { type: :string, example: 'USA' },
          timezone: { type: :string, example: 'America/New_York' },
          currency: { type: :string, example: 'USD' },
          settings: { type: :object },
          pricing_config: { type: :object }
        },
        required: ['slug', 'name']
      }

      response(201, 'Tenant created') do
        schema type: :object,
          properties: {
            tenant: { type: :object }
          }
        run_test!
      end

      response(422, 'Validation failed') do
        run_test!
      end
    end
  end

  path '/api/v1/tenants/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Tenant ID'

    get('Get tenant details') do
      tags 'Tenants'
      description 'Get details of a specific tenant'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'successful') do
        schema type: :object,
          properties: {
            tenant: {
              type: :object,
              properties: {
                id: { type: :string },
                slug: { type: :string },
                name: { type: :string },
                subdomain: { type: :string },
                status: { type: :string },
                region: { type: :string }
              }
            }
          }
        run_test!
      end

      response(404, 'Tenant not found') do
        run_test!
      end
    end

    patch('Update tenant') do
      tags 'Tenants'
      description 'Update tenant details (super admin only)'
      consumes 'application/json'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :tenant, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          status: { type: :string, enum: ['active', 'inactive', 'suspended'] },
          region: { type: :string },
          settings: { type: :object },
          pricing_config: { type: :object }
        }
      }

      response(200, 'Tenant updated') do
        run_test!
      end

      response(422, 'Update failed') do
        run_test!
      end
    end

    delete('Delete tenant') do
      tags 'Tenants'
      description 'Delete a tenant (super admin only)'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(204, 'Tenant deleted') do
        run_test!
      end

      response(403, 'Forbidden') do
        run_test!
      end
    end
  end

  path '/api/v1/tenants/{id}/stats' do
    parameter name: 'id', in: :path, type: :string, description: 'Tenant ID'

    get('Get tenant statistics') do
      tags 'Tenants'
      description 'Get usage statistics for a tenant'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'successful') do
        schema type: :object,
          properties: {
            stats: {
              type: :object,
              properties: {
                total_drivers: { type: :integer },
                active_drivers: { type: :integer },
                total_riders: { type: :integer },
                total_rides: { type: :integer },
                completed_rides: { type: :integer },
                revenue: { type: :number }
              }
            }
          }
        run_test!
      end
    end
  end
end


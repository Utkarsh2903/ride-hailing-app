require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/register' do
    post('Register new user') do
      tags 'Authentication'
      description 'Register a new user account (rider or driver)'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true, description: 'Tenant identifier'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          phone: { type: :string, example: '+1234567890' },
          password: { type: :string, example: 'password123' },
          password_confirmation: { type: :string, example: 'password123' },
          name: { type: :string, example: 'John Doe' },
          role: { type: :string, enum: ['rider', 'driver'], example: 'rider' }
        },
        required: ['email', 'phone', 'password', 'password_confirmation', 'name', 'role']
      }

      response(201, 'User registered successfully') do
        schema type: :object,
          properties: {
            user: { type: :object },
            token: { type: :string }
          }
        run_test!
      end

      response(422, 'Validation failed') do
        run_test!
      end
    end
  end

  path '/api/v1/auth/login' do
    post('Login user') do
      tags 'Authentication'
      description 'Login with email and password to get JWT token'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true, description: 'Tenant identifier'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'admin@test.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      response(200, 'Login successful') do
        schema type: :object,
          properties: {
            token: { type: :string, description: 'JWT token for authentication' },
            user: {
              type: :object,
              properties: {
                id: { type: :string },
                email: { type: :string },
                name: { type: :string },
                role: { type: :string }
              }
            }
          }
        run_test!
      end

      response(401, 'Invalid credentials') do
        run_test!
      end
    end
  end

  path '/api/v1/auth/me' do
    get('Get current user') do
      tags 'Authentication'
      description 'Get current authenticated user details'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer TOKEN'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            user: { type: :object }
          }
        run_test!
      end

      response(401, 'Unauthorized') do
        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    post('Logout user') do
      tags 'Authentication'
      description 'Logout current user (optional, JWT is stateless)'
      produces 'application/json'
      security [{ Bearer: [], TenantID: [] }]
      
      parameter name: 'X-Tenant-ID', in: :header, type: :string, required: true
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response(200, 'Logged out successfully') do
        run_test!
      end
    end
  end
end


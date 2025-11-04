require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/register' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        required: ['email', 'phone', 'password', 'password_confirmation', 'first_name', 'last_name', 'role'],
        properties: {
          email: { 
            type: :string, 
            format: :email,
            example: 'john@example.com',
            description: 'Valid email address'
          },
          phone: { 
            type: :string,
            pattern: '^\+?[1-9]\d{1,14}$',
            example: '+1234567890',
            description: 'Phone number in E.164 format'
          },
          password: { 
            type: :string,
            minLength: 8,
            maxLength: 128,
            example: 'Password123',
            description: 'Must contain uppercase, lowercase, and number'
          },
          password_confirmation: { 
            type: :string,
            example: 'Password123',
            description: 'Must match password'
          },
          first_name: { 
            type: :string,
            minLength: 2,
            maxLength: 50,
            example: 'John',
            description: 'First name (2-50 characters)'
          },
          last_name: { 
            type: :string,
            minLength: 2,
            maxLength: 50,
            example: 'Doe',
            description: 'Last name (2-50 characters)'
          },
          role: { 
            type: :string,
            enum: ['rider', 'driver'],
            example: 'rider',
            description: 'User role: rider or driver'
          }
        }
      }

      response '201', 'user registered' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 user: { '$ref' => '#/components/schemas/User' },
                 token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
               }
        
        let(:user) do
          {
            email: 'john@example.com',
            phone: '+1234567890',
            password: 'Password123',
            password_confirmation: 'Password123',
            first_name: 'John',
            last_name: 'Doe',
            role: 'rider'
          }
        end
        
        run_test!
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:user) { { email: 'invalid' } }
        
        run_test!
      end
    end
  end

  path '/api/v1/auth/login' do
    post 'Login user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        required: ['email', 'password'],
        properties: {
          email: { type: :string, format: :email, example: 'john@example.com' },
          password: { type: :string, example: 'Password123' }
        }
      }

      response '200', 'login successful' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 user: { '$ref' => '#/components/schemas/User' },
                 token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
               }
        
        let(:credentials) { { email: 'john@example.com', password: 'Password123' } }
        
        run_test!
      end

      response '401', 'invalid credentials' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:credentials) { { email: 'john@example.com', password: 'wrong' } }
        
        run_test!
      end
    end
  end

  path '/api/v1/auth/me' do
    get 'Get current user' do
      tags 'Authentication'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'user details' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 user: { '$ref' => '#/components/schemas/User' }
               }
        
        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/Error'
        
        run_test!
      end
    end
  end
end


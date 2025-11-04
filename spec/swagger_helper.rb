# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Ride Hailing API',
        version: 'v1',
        description: 'A multi-tenant, multi-region ride-hailing platform API similar to Uber/Ola. ' \
                     'This API provides endpoints for rider requests, driver-rider matching, ' \
                     'trip lifecycle management, payments, and real-time notifications.',
        contact: {
          name: 'API Support',
          email: 'api@ridehailing.com'
        },
        license: {
          name: 'Proprietary',
          url: 'https://ridehailing.com/license'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.ridehailing.com',
          description: 'Production server'
        },
        {
          url: 'https://staging-api.ridehailing.com',
          description: 'Staging server'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtained from /api/v1/auth/login or /api/v1/auth/register'
          }
        },
        schemas: {
          # Common schemas
          Error: {
            type: :object,
            properties: {
              success: { type: :boolean, example: false },
              error: {
                type: :array,
                items: { type: :string },
                example: ['Validation failed', 'Pickup latitude is required']
              }
            }
          },
          Pagination: {
            type: :object,
            properties: {
              current_page: { type: :integer, example: 1 },
              total_pages: { type: :integer, example: 10 },
              total_count: { type: :integer, example: 95 },
              per_page: { type: :integer, example: 20 }
            }
          },
          # User schemas
          User: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              email: { type: :string, example: 'john@example.com' },
              phone: { type: :string, example: '+1234567890' },
              first_name: { type: :string, example: 'John' },
              last_name: { type: :string, example: 'Doe' },
              role: { type: :string, enum: ['rider', 'driver', 'admin'], example: 'rider' },
              status: { type: :string, enum: ['active', 'suspended', 'inactive'], example: 'active' }
            }
          },
          # Ride schemas
          Ride: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              status: { type: :string, enum: ['requested', 'searching', 'accepted', 'driver_arrived', 'in_progress', 'completed', 'cancelled'], example: 'requested' },
              tier: { type: :string, enum: ['economy', 'standard', 'premium', 'suv', 'luxury'], example: 'standard' },
              pickup: {
                type: :object,
                properties: {
                  latitude: { type: :number, format: :float, example: 40.7128 },
                  longitude: { type: :number, format: :float, example: -74.0060 },
                  address: { type: :string, example: '123 Main St, New York, NY 10001' }
                }
              },
              dropoff: {
                type: :object,
                properties: {
                  latitude: { type: :number, format: :float, example: 40.7589 },
                  longitude: { type: :number, format: :float, example: -73.9851 },
                  address: { type: :string, example: '456 Park Ave, New York, NY 10022' }
                }
              },
              estimated_fare: { type: :number, format: :float, example: 15.50 },
              surge_multiplier: { type: :number, format: :float, example: 1.5 },
              estimated_distance: { type: :number, format: :float, example: 5.2 },
              estimated_duration: { type: :integer, example: 15 },
              payment_method: { type: :string, enum: ['card', 'cash', 'wallet'], example: 'card' },
              payment_status: { type: :string, enum: ['pending', 'paid', 'failed', 'refunded'], example: 'pending' },
              timestamps: {
                type: :object,
                properties: {
                  requested_at: { type: :string, format: 'date-time', example: '2025-01-03T10:00:00Z' },
                  accepted_at: { type: :string, format: 'date-time', nullable: true },
                  started_at: { type: :string, format: 'date-time', nullable: true },
                  completed_at: { type: :string, format: 'date-time', nullable: true },
                  cancelled_at: { type: :string, format: 'date-time', nullable: true }
                }
              }
            }
          },
          # Driver schemas
          Driver: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'John Doe' },
              phone: { type: :string, example: '+1234567890' },
              rating: { type: :number, format: :float, example: 4.8 },
              total_trips: { type: :integer, example: 150 },
              completed_trips: { type: :integer, example: 148 },
              vehicle: {
                type: :object,
                properties: {
                  type: { type: :string, enum: ['economy', 'standard', 'premium', 'suv', 'luxury'], example: 'standard' },
                  model: { type: :string, example: 'Toyota Camry' },
                  plate: { type: :string, example: 'ABC-1234' },
                  year: { type: :integer, example: 2022 }
                }
              },
              status: { type: :string, enum: ['offline', 'online', 'on_trip', 'inactive'], example: 'online' }
            }
          },
          # Trip schemas
          Trip: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              status: { type: :string, enum: ['in_progress', 'completed', 'cancelled'], example: 'completed' },
              actual_distance: { type: :number, format: :float, example: 5.4 },
              actual_duration: { type: :integer, example: 18 },
              total_fare: { type: :number, format: :float, example: 16.75 },
              timestamps: {
                type: :object,
                properties: {
                  started_at: { type: :string, format: 'date-time', example: '2025-01-03T10:15:00Z' },
                  ended_at: { type: :string, format: 'date-time', example: '2025-01-03T10:33:00Z' }
                }
              },
              fare_breakdown: {
                type: :object,
                properties: {
                  base_fare: { type: :number, format: :float, example: 3.50 },
                  distance_fare: { type: :number, format: :float, example: 8.10 },
                  time_fare: { type: :number, format: :float, example: 3.60 },
                  surge_amount: { type: :number, format: :float, example: 1.55 },
                  waiting_charge: { type: :number, format: :float, example: 0.00 },
                  service_fee: { type: :number, format: :float, example: 1.52 },
                  tax_amount: { type: :number, format: :float, example: 0.83 },
                  tip_amount: { type: :number, format: :float, example: 0.00 }
                }
              }
            }
          },
          # Payment schemas
          Payment: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              status: { type: :string, enum: ['pending', 'processing', 'completed', 'failed', 'refunded'], example: 'completed' },
              amount: { type: :number, format: :float, example: 16.75 },
              payment_method: { type: :string, enum: ['card', 'cash', 'wallet'], example: 'card' },
              transaction_id: { type: :string, example: 'txn_abc123xyz' },
              timestamps: {
                type: :object,
                properties: {
                  initiated_at: { type: :string, format: 'date-time', example: '2025-01-03T10:33:00Z' },
                  completed_at: { type: :string, format: 'date-time', example: '2025-01-03T10:33:05Z' },
                  failed_at: { type: :string, format: 'date-time', nullable: true }
                }
              },
              split: {
                type: :object,
                properties: {
                  platform_fee: { type: :number, format: :float, example: 3.35 },
                  driver_amount: { type: :number, format: :float, example: 13.40 }
                }
              }
            }
          }
        }
      },
      tags: [
        {
          name: 'Authentication',
          description: 'User authentication and authorization endpoints'
        },
        {
          name: 'Rides',
          description: 'Ride request and management endpoints'
        },
        {
          name: 'Drivers',
          description: 'Driver-specific endpoints including location updates and ride acceptance'
        },
        {
          name: 'Trips',
          description: 'Trip lifecycle management endpoints'
        },
        {
          name: 'Payments',
          description: 'Payment processing and management endpoints'
        },
        {
          name: 'Tenants',
          description: 'Multi-tenant management endpoints (admin only)'
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end


# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Ride Hailing API',
        version: 'v1',
        description: 'Multi-tenant ride-hailing platform API with real-time driver tracking, dynamic pricing, and payment integration.'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:8080'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token for authentication. Obtain from /api/v1/auth/login'
          },
          TenantID: {
            type: :apiKey,
            in: :header,
            name: 'X-Tenant-ID',
            description: 'Tenant identifier (e.g., "test")'
          }
        },
        schemas: {
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              message: { type: :string },
              status: { type: :integer }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  config.swagger_format = :yaml
end


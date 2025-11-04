# Base validator concern with common validation patterns
# Reduces boilerplate while maintaining strict validations
module BaseValidator
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Validations
  end

  class_methods do
    # Validate coordinates (latitude/longitude)
    def validates_coordinate(attribute, type:)
      validates attribute, presence: { message: "is required" }
      
      if type == :latitude
        validates attribute, numericality: {
          greater_than_or_equal_to: -90,
          less_than_or_equal_to: 90,
          message: "must be between -90 and 90 degrees"
        }
      elsif type == :longitude
        validates attribute, numericality: {
          greater_than_or_equal_to: -180,
          less_than_or_equal_to: 180,
          message: "must be between -180 and 180 degrees"
        }
      end
    end

    # Validate enum values
    def validates_enum(attribute, values:, allow_nil: false)
      validates attribute, inclusion: {
        in: values,
        message: "must be one of: #{values.join(', ')}"
      }, allow_nil: allow_nil
    end

    # Validate positive number
    def validates_positive_number(attribute, max: nil, allow_nil: true)
      options = {
        greater_than: 0,
        message: "must be a positive number"
      }
      options[:less_than_or_equal_to] = max if max
      
      validates attribute, numericality: options, allow_nil: allow_nil
    end

    # Validate phone number (E.164 format)
    def validates_phone_number(attribute)
      validates attribute,
                presence: { message: "is required" },
                format: {
                  with: /\A\+?[1-9]\d{1,14}\z/,
                  message: "must be a valid phone number (E.164 format)"
                }
    end

    # Validate email
    def validates_email(attribute)
      validates attribute,
                presence: { message: "is required" },
                format: {
                  with: URI::MailTo::EMAIL_REGEXP,
                  message: "must be a valid email address"
                },
                length: { maximum: 255 }
    end
  end

  # Convert to hash (removes nil values)
  def to_h
    attributes.each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value if value.present?
    end
  end

  # Class method to create from params
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def from_params(params)
      new(params.to_h)
    end
  end

  private

  # Helper to get all attributes dynamically
  def attributes
    self.class.attribute_names.each_with_object({}) do |attr, hash|
      hash[attr] = public_send(attr)
    end
  end
end


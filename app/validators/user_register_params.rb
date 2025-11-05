# Validator for user registration parameters
class UserRegisterParams
  include BaseValidator

  attr_accessor :email, :phone, :password, :password_confirmation,
                :name, :role, :driver_attributes

  # Email validation using base validator
  validates_email :email

  # Phone validation using base validator
  validates_phone_number :phone

  # Password validation (simplified for testing)
  validates :password,
            presence: { message: "is required" },
            length: {
              minimum: 6,
              maximum: 128,
              message: "must be between 6 and 128 characters"
            }

  validates :password_confirmation, presence: { message: "is required" }

  # Custom password validations
  validate :password_match

  # Name validations
  validates :name,
            presence: { message: "is required" },
            length: {
              minimum: 2,
              maximum: 100,
              message: "must be between 2 and 100 characters"
            }

  # Role validation using base validator
  validates_enum :role, values: %w[rider driver]

  # Driver attributes validation
  validate :driver_attributes_present_if_driver

  # Convert to service-ready hash
  def to_h
    hash = {
      email: email.downcase.strip,
      phone: phone.strip,
      password: password,
      password_confirmation: password_confirmation,
      name: name.strip,
      role: role
    }

    # Add nested driver attributes if present
    if driver_attributes.present?
      hash[:driver_attributes] = {
        license_number: driver_attributes[:license_number],
        vehicle_type: driver_attributes[:vehicle_type],
        vehicle_model: driver_attributes[:vehicle_model]
      }
    end

    hash
  end

  private

  def password_match
    return unless password.present? && password_confirmation.present?

    if password != password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end

  def driver_attributes_present_if_driver
    return unless role == 'driver'

    if driver_attributes.blank?
      errors.add(:driver_attributes, "are required for driver registration")
      return
    end

    if driver_attributes[:license_number].blank?
      errors.add(:'driver_attributes.license_number', "is required")
    end

    if driver_attributes[:vehicle_type].blank?
      errors.add(:'driver_attributes.vehicle_type', "is required")
    end

    # Validate vehicle_type enum
    valid_types = %w[sedan suv economy standard premium luxury]
    if driver_attributes[:vehicle_type].present? && !valid_types.include?(driver_attributes[:vehicle_type])
      errors.add(:'driver_attributes.vehicle_type', "must be one of: #{valid_types.join(', ')}")
    end
  end
end

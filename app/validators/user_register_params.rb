# Validator for user registration parameters
class UserRegisterParams
  include BaseValidator

  attr_accessor :email, :phone, :password, :password_confirmation,
                :first_name, :last_name, :role

  # Email validation using base validator
  validates_email :email

  # Phone validation using base validator
  validates_phone_number :phone

  # Password validation
  validates :password,
            presence: { message: "is required" },
            length: {
              minimum: 8,
              maximum: 128,
              message: "must be between 8 and 128 characters"
            }

  validates :password_confirmation, presence: { message: "is required" }

  # Custom password validations
  validate :password_match
  validate :password_complexity

  # Name validations
  validates :first_name, :last_name,
            presence: { message: "is required" },
            length: {
              minimum: 2,
              maximum: 50,
              message: "must be between 2 and 50 characters"
            },
            format: {
              with: /\A[a-zA-Z\s\-']+\z/,
              message: "can only contain letters, spaces, hyphens, and apostrophes"
            }

  # Role validation using base validator
  validates_enum :role, values: %w[rider driver]

  # Convert to service-ready hash
  def to_h
    {
      email: email.downcase.strip,
      phone: phone.strip,
      password: password,
      password_confirmation: password_confirmation,
      first_name: first_name.strip,
      last_name: last_name.strip,
      role: role
    }
  end

  private

  def password_match
    return unless password.present? && password_confirmation.present?

    if password != password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end

  def password_complexity
    return unless password.present?

    unless password.match?(/[A-Z]/)
      errors.add(:password, "must contain at least one uppercase letter")
    end

    unless password.match?(/[a-z]/)
      errors.add(:password, "must contain at least one lowercase letter")
    end

    unless password.match?(/[0-9]/)
      errors.add(:password, "must contain at least one number")
    end
  end
end

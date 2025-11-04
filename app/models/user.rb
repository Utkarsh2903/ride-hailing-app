# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email           :string           not null
#  phone           :string           not null
#  password_digest :string           not null
#  name            :string           not null
#  role            :string           default("rider"), not null
#  status          :string           default("active"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  include TenantScoped

  has_secure_password

  # Enums
  enum role: { rider: 0, driver: 1, admin: 2, super_admin: 3 }
  enum status: { active: 0, suspended: 1, inactive: 2 }

  # Associations
  has_one :driver, dependent: :destroy
  has_one :rider, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, uniqueness: true, format: { with: /\A\+?[1-9]\d{1,14}\z/ }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :create_role_specific_record

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def create_role_specific_record
    create_rider! if rider? && rider.blank?
    # Driver record created manually with vehicle info
  end
end


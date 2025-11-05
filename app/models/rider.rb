# == Schema Information
#
# Table name: riders
#
#  id                       :uuid             not null, primary key
#  user_id                  :uuid             not null
#  rating                   :decimal(3, 2)    default(5.0)
#  completed_trips          :integer          default(0)
#  cancelled_trips          :integer          default(0)
#  preferred_payment_method :string           default("card")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Rider < ApplicationRecord
  include TenantScoped

  VALID_PAYMENT_METHODS = %w[card cash wallet].freeze

  # Associations
  belongs_to :user
  has_many :rides, dependent: :destroy
  has_many :completed_rides, -> { where(status: 'completed') }, class_name: 'Ride'
  has_many :payments, dependent: :nullify

  # Validations
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :preferred_payment_method, inclusion: { in: VALID_PAYMENT_METHODS }, allow_nil: true

  # Scopes
  scope :high_rated, -> { where('rating >= ?', 4.5) }
  scope :frequent, -> { where('completed_trips >= ?', 10) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def active_ride
    rides.where(status: %w[requested accepted driver_arrived in_progress]).first
  end

  def has_active_ride?
    active_ride.present?
  end

  def cancellation_rate
    return 0.0 if completed_trips.zero?
    (cancelled_trips.to_f / (completed_trips + cancelled_trips) * 100).round(2)
  end
end


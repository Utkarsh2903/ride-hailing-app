# == Schema Information
#
# Table name: rides
#
#  id                  :uuid             not null, primary key
#  rider_id            :uuid             not null
#  driver_id           :uuid
#  status              :string           default("requested"), not null
#  tier                :string           default("standard"), not null
#  pickup_location     :geography        point, 4326
#  pickup_latitude     :decimal(10, 6)   not null
#  pickup_longitude    :decimal(10, 6)   not null
#  pickup_address      :string
#  dropoff_location    :geography        point, 4326
#  dropoff_latitude    :decimal(10, 6)   not null
#  dropoff_longitude   :decimal(10, 6)   not null
#  dropoff_address     :string
#  estimated_fare      :decimal(10, 2)
#  surge_multiplier    :decimal(5, 2)    default(1.0)
#  estimated_distance  :decimal(10, 2)
#  estimated_duration  :integer
#  payment_method      :string           default("card"), not null
#  payment_status      :string           default("pending")
#  requested_at        :datetime
#  accepted_at         :datetime
#  driver_arrived_at   :datetime
#  started_at          :datetime
#  completed_at        :datetime
#  cancelled_at        :datetime
#  cancelled_by        :string
#  cancellation_reason :string
#  idempotency_key     :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Ride < ApplicationRecord
  include AASM
  include TenantScoped

  # Enums
  enum tier: { economy: 0, standard: 1, premium: 2, suv: 3, luxury: 4 }
  enum payment_method: { card: 0, cash: 1, wallet: 2 }
  enum payment_status: { pending: 0, paid: 1, failed: 2, refunded: 3 }
  enum cancelled_by: { rider: 0, driver: 1, system: 2 }

  # Associations
  belongs_to :rider
  belongs_to :driver, optional: true
  has_one :trip, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many :driver_assignments, dependent: :destroy

  # Validations
  validates :status, presence: true
  validates :pickup_latitude, :pickup_longitude, :dropoff_latitude, :dropoff_longitude, presence: true
  validates :pickup_latitude, :dropoff_latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :pickup_longitude, :dropoff_longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :surge_multiplier, numericality: { greater_than: 0 }
  validates :idempotency_key, presence: true, uniqueness: true

  # Callbacks
  before_validation :set_idempotency_key, on: :create
  before_create :set_requested_at
  before_create :calculate_estimates

  # State Machine
  aasm column: :status do
    state :requested, initial: true
    state :searching
    state :accepted
    state :driver_arrived
    state :in_progress
    state :completed
    state :cancelled
    state :failed

    event :start_searching do
      transitions from: :requested, to: :searching
    end

    event :accept do
      transitions from: [:searching, :requested], to: :accepted
      after do
        update_columns(accepted_at: Time.current)
      end
    end

    event :mark_driver_arrived do
      transitions from: :accepted, to: :driver_arrived
      after do
        update_columns(driver_arrived_at: Time.current)
      end
    end

    event :start do
      transitions from: :driver_arrived, to: :in_progress
      after do
        update_columns(started_at: Time.current)
        driver&.start_trip!
      end
    end

    event :complete do
      transitions from: :in_progress, to: :completed
      after do
        update_columns(completed_at: Time.current, payment_status: 'pending')
        driver&.end_trip!
      end
    end

    event :cancel do
      transitions from: [:requested, :searching, :accepted, :driver_arrived], to: :cancelled
      after do
        update_columns(cancelled_at: Time.current)
      end
    end

    event :fail do
      transitions from: [:requested, :searching, :accepted], to: :failed
    end
  end

  # Scopes
  scope :active, -> { where(status: %w[requested searching accepted driver_arrived in_progress]) }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :pending_payment, -> { where(payment_status: 'pending') }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_surge, -> { where('surge_multiplier > ?', 1.0) }

  # Instance methods
  def can_be_cancelled?
    %w[requested searching accepted driver_arrived].include?(status)
  end

  def assign_driver!(driver)
    update!(driver: driver)
    accept!
  end

  def distance_between_points
    return nil unless pickup_latitude && pickup_longitude && dropoff_latitude && dropoff_longitude
    
    Geocoder::Calculations.distance_between(
      [pickup_latitude, pickup_longitude],
      [dropoff_latitude, dropoff_longitude],
      units: :km
    )
  end

  def formatted_estimated_fare
    "$#{estimated_fare&.round(2)}"
  end

  private

  def set_idempotency_key
    self.idempotency_key ||= SecureRandom.uuid
  end

  def set_requested_at
    self.requested_at = Time.current
  end

  def calculate_estimates
    # Calculate estimated distance using Haversine formula
    self.estimated_distance = calculate_distance_km

    # Estimate duration (assuming average speed of 30 km/h in city)
    self.estimated_duration = (estimated_distance / 30.0 * 60).to_i if estimated_distance

    # Calculate estimated fare
    self.estimated_fare = calculate_estimated_fare
  end

  def calculate_distance_km
    rad_per_deg = Math::PI / 180
    rm = 6371 # Earth radius in kilometers

    dlat_rad = (dropoff_latitude - pickup_latitude) * rad_per_deg
    dlon_rad = (dropoff_longitude - pickup_longitude) * rad_per_deg

    lat1_rad = pickup_latitude * rad_per_deg
    lat2_rad = dropoff_latitude * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    (rm * c).round(2)
  end

  def calculate_estimated_fare
    return nil unless estimated_distance

    # Base fare by tier
    base_fares = { economy: 2.50, standard: 3.50, premium: 5.00, suv: 6.00, luxury: 10.00 }
    per_km_rates = { economy: 1.00, standard: 1.50, premium: 2.50, suv: 3.00, luxury: 5.00 }

    base = base_fares[tier.to_sym] || 3.50
    per_km = per_km_rates[tier.to_sym] || 1.50

    fare = base + (estimated_distance * per_km)
    (fare * surge_multiplier).round(2)
  end
end


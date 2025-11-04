# == Schema Information
#
# Table name: drivers
#
#  id                :uuid             not null, primary key
#  user_id           :uuid             not null
#  license_number    :string           not null
#  vehicle_type      :string           not null
#  vehicle_model     :string
#  vehicle_plate     :string           not null
#  vehicle_year      :integer
#  status            :string           default("offline"), not null
#  rating            :decimal(3, 2)    default(5.0)
#  total_trips       :integer          default(0)
#  accepted_trips    :integer          default(0)
#  completed_trips   :integer          default(0)
#  cancelled_trips   :integer          default(0)
#  last_active_at    :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Driver < ApplicationRecord
  include AASM
  include TenantScoped

  # Enums
  enum vehicle_type: { economy: 0, standard: 1, premium: 2, suv: 3, luxury: 4 }

  # Associations
  belongs_to :user
  has_many :driver_locations, dependent: :destroy
  has_many :rides, dependent: :nullify
  has_many :completed_rides, -> { where(status: 'completed') }, class_name: 'Ride'
  has_many :driver_assignments, dependent: :destroy
  has_many :payments, dependent: :nullify

  # Validations
  validates :license_number, presence: true, uniqueness: true
  validates :vehicle_plate, presence: true, uniqueness: true
  validates :vehicle_year, numericality: { only_integer: true, greater_than: 1990, less_than_or_equal_to: -> { Time.current.year + 1 } }, allow_nil: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  # State Machine
  aasm column: :status do
    state :offline, initial: true
    state :online
    state :on_trip
    state :inactive

    event :go_online do
      transitions from: [:offline, :inactive], to: :online
      after do
        update_column(:last_active_at, Time.current)
      end
    end

    event :go_offline do
      transitions from: [:online, :on_trip], to: :offline
    end

    event :start_trip do
      transitions from: :online, to: :on_trip
    end

    event :end_trip do
      transitions from: :on_trip, to: :online
      after do
        update_column(:last_active_at, Time.current)
      end
    end

    event :deactivate do
      transitions from: [:offline, :online], to: :inactive
    end
  end

  # Scopes
  scope :online, -> { where(status: 'online') }
  scope :available, -> { online.where.not(id: Ride.in_progress.select(:driver_id)) }
  scope :high_rated, -> { where('rating >= ?', 4.5) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def available?
    online? && !currently_on_trip?
  end

  def currently_on_trip?
    rides.in_progress.exists?
  end

  def current_location
    driver_locations.order(recorded_at: :desc).first
  end

  def acceptance_rate
    return 100.0 if total_trips.zero?
    (accepted_trips.to_f / total_trips * 100).round(2)
  end

  def cancellation_rate
    return 0.0 if completed_trips.zero?
    (cancelled_trips.to_f / (completed_trips + cancelled_trips) * 100).round(2)
  end
end


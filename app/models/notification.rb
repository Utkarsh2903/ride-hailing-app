# == Schema Information
#
# Table name: notifications
#
#  id                :uuid             not null, primary key
#  user_id           :uuid             not null
#  notification_type :string           not null
#  title             :string           not null
#  body              :text
#  data              :jsonb
#  read_at           :datetime
#  channel           :string
#  status            :string           default("pending")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Notification < ApplicationRecord
  include TenantScoped

  # Enums
  enum channel: { push: 0, websocket: 1, sms: 2, email: 3 }
  enum status: { pending: 0, sent: 1, delivered: 2, failed: 3 }

  # Associations
  belongs_to :user

  # Validations
  validates :notification_type, presence: true
  validates :title, presence: true

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }

  # Instance methods
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
end


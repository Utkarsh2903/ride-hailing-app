# Service for sending notifications to users
# Implements Observer Pattern for multi-channel notifications
class NotificationService < ApplicationService
  def initialize(user:, type:, title:, body: nil, data: {}, channels: [:push])
    @user = user
    @type = type
    @title = title
    @body = body
    @data = data
    @channels = Array(channels)
  end

  def call
    notification = create_notification

    send_notifications(notification)

    success(notification: notification)
  rescue StandardError => e
    failure("Notification failed: #{e.message}")
  end

  private

  def create_notification
    Notification.create!(
      user: @user,
      notification_type: @type,
      title: @title,
      body: @body,
      data: @data,
      status: 'pending'
    )
  end

  def send_notifications(notification)
    @channels.each do |channel|
      case channel
      when :push
        send_push_notification(notification)
      when :sms
        send_sms_notification(notification)
      when :email
        send_email_notification(notification)
      end
    end

    notification.mark_as_sent!
  end

  def send_push_notification(notification)
    # Integrate with Firebase Cloud Messaging or similar
    # PushNotificationJob.perform_later(notification.id)
  end

  def send_sms_notification(notification)
    # Integrate with Twilio or similar
    # SmsNotificationJob.perform_later(notification.id)
  end

  def send_email_notification(notification)
    # Send email via Action Mailer
    # NotificationMailer.notify(@user, notification).deliver_later
  end
end


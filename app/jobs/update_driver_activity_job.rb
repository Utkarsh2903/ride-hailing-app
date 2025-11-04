# Job to update driver's last_active_at timestamp
# Async to avoid blocking location updates
class UpdateDriverActivityJob < ApplicationJob
  queue_as :low_priority
  
  def perform(driver_id)
    driver = Driver.find(driver_id)
    driver.touch(:last_active_at)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Driver #{driver_id} not found for activity update"
  end
end


# Simple concern for validating coordinates
# Following Rails conventions with ActiveModel validations
module CoordinateValidatable
  extend ActiveSupport::Concern

  class_methods do
    def validates_latitude(attribute)
      validates attribute,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: -90,
                  less_than_or_equal_to: 90
                }
    end

    def validates_longitude(attribute)
      validates attribute,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: -180,
                  less_than_or_equal_to: 180
                }
    end
  end
end


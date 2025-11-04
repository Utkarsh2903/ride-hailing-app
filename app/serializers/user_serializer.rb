# Serializer for User responses
# Follows Single Responsibility Principle
class UserSerializer
  include JSONAPI::Serializer

  attributes :email, :phone, :first_name, :last_name, :full_name, :role, :status
  
  attribute :created_at do |user|
    user.created_at.iso8601
  end
end


class User < ApplicationRecord
  
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  has_many :loans
  enum  role: {user: 0, admin: 1}
  
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "encrypted_password", "id", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "updated_at", "wallet"]
  end

  def generate_jwt
    JsonWebToken.encode(user_id: self.id)
  end
end

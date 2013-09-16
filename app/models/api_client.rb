class ApiClient < ActiveRecord::Base
  validates :name, :app_token, :app_secret, presence: true, uniqueness: true

  def self.for_app_token(token)
    where(app_token: token).first
  end

  def self.for_app_secret(token)
    where(app_secret: token).first
  end

  before_validation :generate_tokens
  def generate_tokens
    self.app_token ||= SecureRandom.hex(16)
    self.app_secret ||= SecureRandom.hex(16)
  end
end

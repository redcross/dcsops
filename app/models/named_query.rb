class NamedQuery < ApplicationRecord
  before_create :generate_token

  def generate_token
    self.token = SecureRandom.hex(10) if self.token.blank?
  end
end

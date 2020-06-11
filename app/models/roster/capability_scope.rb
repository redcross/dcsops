class Roster::CapabilityScope < ApplicationRecord
  belongs_to :capability_membership

  def scope
    val = super
    if val =~ /\A\d+\z/
      val.to_i
    else
      val
    end
  end
end

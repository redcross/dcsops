class Incidents::PartnerUse < ApplicationRecord
  belongs_to :incident, class_name: 'Incidents::PartnerUse'
  belongs_to :partner, class_name: 'Partners::Partner'

  validates :partner, presence: true

  validates :meals_served, presence: {if: ->(rec){rec.role == 'feeding'}}
  validates :hotel_rooms, :hotel_rate, presence: {if: ->(rec){rec.role == 'hotel'}}

  attr_writer :partner_name
  def partner_name
    partner.try(:name) || @partner_name
  end

  def assign_attributes(val)
    super(val)
  end

  before_validation :maybe_create_partner
  def maybe_create_partner
    if partner_name.present? and partner_id.nil?
      build_partner name: partner_name, region: incident.region
    end
  end
end

module Incidents::IncidentPartners
  extend ActiveSupport::Concern

  included do
    {evac_partner: 'evac_center', hotel_partner: 'hotel', shelter_partner: 'shelter', feeding_partner: 'feeding'}.each do |attr, role|
      has_one :"#{attr}_use", -> { where(role: role) }, class_name: 'Incidents::PartnerUse'

      accepts_nested_attributes_for :"#{attr}_use", update_only: true, reject_if: -> attrs { attrs[:partner_id].blank? && attrs[:partner_name].blank? }
      validates_presence_of :"#{attr}_use", if: :"#{attr}_used"
      validates_associated :"#{attr}_use", if: :"#{attr}_used"
      #attr_accessor :"#{attr}_used"
      #define_method :"#{attr}_used=" do |val|
      #  coerced = case val
      #  when TrueClass, FalseClass then val
      #  when String then val=='1'
      #  else false
      #  end
      #  write_attribute("@#{attr}_used", coerced)
      #end

      before_validation :"clean_#{attr}_use"
      define_method :"clean_#{attr}_use" do
        use = self.send :"#{attr}_use"
        used = self.send :"#{attr}_used"
        if !used and use
          use.destroy
          self.send(:"#{attr}_use=", nil)
        end
      end
    end
  end
end
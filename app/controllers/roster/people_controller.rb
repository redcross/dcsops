class Roster::PeopleController < InheritedResources::Base
  respond_to :html, :json

  has_scope :search_name
  has_scope :in_county
  has_scope :with_position, type: :array

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      [params.require(:roster_person).permit(:first_name, :last_name, :email, 
              :home_phone, :cell_phone, :work_phone, :alternate_phone, :sms_phone, 
              :home_phone_carrier_id, :cell_phone_carrier_id, :work_phone_carrier_id, :alternate_phone_carrier_id, :sms_phone_carrier_id, 
              :home_phone_disable, :cell_phone_disable, :work_phone_disable, :alternate_phone_disable, :sms_phone_disable, 
              :phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference, 
              :address, :city, :state, :zip, :vc_id)]
    end

    def collection
      apply_scopes(super)
    end
end

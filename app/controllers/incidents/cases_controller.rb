class Incidents::CasesController < Incidents::EditPanelController
  self.panel_name = 'cases'
  
  protected

  def build_resource
    super.tap{|r|
      r.address ||= parent.address
      r.city ||= parent.city
      r.state ||= parent.state
      r.zip ||= parent.zip
      r.lat ||= parent.lat
      r.lng ||= parent.lng
    }
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_case).permit(:first_name, :last_name, :num_adults, :num_children, :unit, :address, :city, :state, :zip, :cac_number, :case_assistance_items_attributes => [:id, :price_list_item_id, :quantity, :_destroy])]
  end
end

class Roster::PeopleController < Roster::BaseController
  inherit_resources
  respond_to :html, :json, :kml
  helper EditableHelper

  include NamedQuerySupport
  include Searchable

  has_scope :for_chapter
  has_scope :name_contains
  has_scope :in_county
  has_scope :with_position, type: :array

  load_and_authorize_resource except: :index
  def index
    unless named_query
      params[:for_chapter] ||= current_chapter.id
      chapter = Roster::Chapter.find(params[:for_chapter])
      authorize! :search_people, chapter
    end
    index!
  end

  def me
    redirect_to roster_person_url(current_user)
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      [params.require(:roster_person).permit(
              :home_phone, :cell_phone, :work_phone, :alternate_phone, :sms_phone, 
              :home_phone_carrier_id, :cell_phone_carrier_id, :work_phone_carrier_id, :alternate_phone_carrier_id, :sms_phone_carrier_id, 
              :home_phone_disable, :cell_phone_disable, :work_phone_disable, :alternate_phone_disable, :sms_phone_disable, 
              :phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference)]
    end

    def collection
      @collection ||= apply_scopes(super).joins{chapter}.where(vc_is_active: true).includes{positions}
    end

    expose(:identify_people) { false }

    expose(:cache_key) { "#{request.format}_#{params[:q]}_count#{collection.count}_#{collection.maximum(:updated_at).to_i}" }
end

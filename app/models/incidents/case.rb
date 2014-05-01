class Incidents::Case < Incidents::DataModel
  has_many :case_assistance_items, class_name: 'Incidents::CaseAssistanceItem'

  accepts_nested_attributes_for :case_assistance_items, allow_destroy: true

  validates :first_name, :last_name, :num_adults, :num_children, :unit, :phone_number, presence: true

  before_validation :calculate_total
  def calculate_total
    self.total_amount = case_assistance_items.select{|item| item.valid? && !item.marked_for_destruction?}.map(&:total_price).sum
  end

  def have_case_assistance_items?
    case_assistance_items.select{|item| !item.marked_for_destruction?}.present?
  end

  def cas_case_url
    return unless incident and cas_case_number.present?
    "https://#{incident.chapter.cas_host}/zf/client/render/id/#{cas_case_number}"
  end
end

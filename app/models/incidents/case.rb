class CreditCardNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value = value.gsub(/\D/, '')
    CreditCardValidator::Validator.options.merge!({test_numbers_are_valid: !Rails.env.production?})
    unless CreditCardValidator::Validator.valid? value
      record.errors.add attribute, 'is not a valid card number'
    end
  end
end

class Incidents::Case < Incidents::DataModel
  has_many :case_assistance_items, class_name: 'Incidents::CaseAssistanceItem'

  accepts_nested_attributes_for :case_assistance_items, allow_destroy: true

  validates :first_name, :last_name, :num_adults, :num_children, :unit, :phone_number, presence: true
  validates :cac_number, presence: {if: ->(obj){obj.have_case_assistance_items?}}, credit_card_number: {allow_blank: true}

  before_validation :calculate_total
  def calculate_total
    self.total_amount = case_assistance_items.select{|item| item.valid? && !item.marked_for_destruction?}.map(&:total_price).sum
  end

  before_validation :normalize_cac_number
  def normalize_cac_number
    if cac_number
      self.cac_number = cac_number.gsub(/\D/, '')
    end
  end

  def have_case_assistance_items?
    case_assistance_items.select{|item| !item.marked_for_destruction?}.present?
  end

  def obfuscated_cac
    if cac_number.present?
      "xxxx-xxxx-xxxx-" + cac_number[-4..-1]
    end
  end
end

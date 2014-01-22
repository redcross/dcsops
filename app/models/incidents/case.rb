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
  validates :cac_number, presence: {if: :have_case_assistance_items?}, credit_card_number: {allow_blank: true}

  encrypt_with_public_key :cac_number, public_key: :strongbox_public_key, private_key: :strongbox_private_key, symmetric: :never

  before_validation :calculate_total
  def calculate_total
    self.total_amount = case_assistance_items.select{|item| item.valid? && !item.marked_for_destruction?}.map(&:total_price).sum
  end

  def have_case_assistance_items?
    case_assistance_items.select{|item| !item.marked_for_destruction?}.present?
  end

  before_validation :normalize_cac_number
  def normalize_cac_number
    if cac_number
      self.cac_number = cac_number.gsub(/\D/, '')
    end
  end

  def cac_number
    lock_for(:cac_number).decrypt ''
  end

  after_validation :set_masked_cac
  def set_masked_cac
    if cac_number.present?
      pan_first = cac_number[0..3]
      pan_second = cac_number[4..5]
      last_4 = cac_number[-4..-1]
      self.cac_masked = "#{pan_first}-#{pan_second}xx-xxxx-#{last_4}"
    else
      self.cac_masked = nil
    end
  end

  def strongbox_public_key
    ENV['CAC_PUBLIC_KEY']
  end

  def strongbox_private_key
    ENV['CAC_PRIVATE_KEY']
  end
end

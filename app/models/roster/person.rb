class Roster::Person < ApplicationRecord
  include AutoGeocode
  include Mappable

  PHONE_TYPES = [:cell_phone, :home_phone, :work_phone, :alternate_phone, :sms_phone]

  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :primary_county, class_name: 'Roster::County'

  has_many :county_memberships, class_name: 'Roster::CountyMembership'
  has_many :counties, class_name: 'Roster::County', through: :county_memberships

  has_many :position_memberships, class_name: 'Roster::PositionMembership'
  has_many :positions, class_name: 'Roster::Position', through: :position_memberships
  has_many :role_memberships, class_name: 'Roster::RoleMembership', through: :positions

  belongs_to :home_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :cell_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :work_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :alternate_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :sms_phone_carrier, class_name: 'Roster::CellCarrier'

  scope :name_contains, lambda {|query| 
    where{lower(first_name.op('||', ' ').op('||', last_name)).like("%#{query.downcase}%")}
  }

  scope :for_chapter, ->(chapter){where{chapter_id == chapter}}

  scope :has_role_for_scope, -> role_name, scope {
    joins{roles.role_scopes.outer}.where{(roles.grant_name == role_name) & ((roles.role_scopes.scope == nil) | (roles.role_scopes.scope == scope.to_s))}
  }

  scope :include_carriers, -> {
    includes{[home_phone_carrier, cell_phone_carrier, work_phone_carrier, alternate_phone_carrier, sms_phone_carrier]}
  }

  sifter :with_position do
    (lat != nil) & (lng != nil) & (lat != 0) & (lng != 0)
  end

  def self.for_vc_account(account)
    self.where(vc_id: account).first
  end

  def self.is_active
    where{vc_is_active == true}
  end

  def self.with_phone_number(number)
    where{(home_phone == number) | (cell_phone == number) | (work_phone == number) | (alternate_phone == number) | (sms_phone == number)}
  end

  scope :has_position, lambda { joins{positions} }
  scope :in_county, lambda {|county| joins(:counties).where(:counties => {id: county})}
  scope :with_position, lambda {|positions| joins(:positions).where(:positions => {id: positions})}
  scope :by_name, lambda { order(:last_name, :first_name)}

  has_many :shift_assignments, class_name: 'Scheduler::ShiftAssignment'
  has_one :notification_setting, class_name: 'Scheduler::NotificationSetting', foreign_key: 'id'

  validates *((1..4).map{|n| "phone_#{n}_preference".to_sym}), inclusion: {in: %w(home cell work alternate sms), allow_blank: true}
  validates_presence_of :chapter
  validate :validate_disabled_phones

  #validates_inclusion_of :primary_county_id, in: lambda{ |person| person.chapter.county_ids }, allow_nil: true, allow_blank: true

  default_scope {order(:last_name, :first_name)}

  accepts_nested_attributes_for :county_memberships, :position_memberships, allow_destroy: true

  def has_role(grant_name)
    roles_with_scopes.select{|mem| mem.role.grant_name == grant_name}.present?
  end

  def scope_for_role(grant_name)
    roles_with_scopes.select{|mem| mem.role.grant_name == grant_name}
                     .flat_map{|mem| mem.role_scopes.map(&:scope) }
                     .flat_map{ |scope| scope == 'county_ids' ? county_ids : scope}
                     .compact.uniq
  end

  def roles_with_scopes
    @roles_with_scopes ||= role_memberships.includes{[role, role_scopes]}.joins{role_scopes.outer}.references(:role)
  end

  def primary_county
    super || counties.first
  end

  def primary_county_id
    (read_attribute(:primary_county_id) || counties.first.try(:id))
  end

  def first_initial
    first_name && first_name[0]
  end

  def full_name
    [first_name, last_name].compact.join " "
  end

  def name_last_first
    [last_name, first_name].compact.join ", "
  end

  def primary_phone
    phone = phone_order.first
    phone && phone[:number]
  end

  def full_address
    "#{address1} #{address2} #{city}, #{state}, #{zip}"
  end

  def sms_addresses
    phone_order(sms_only: true).map{|ph| number = ph[:number].gsub(/\D+/, ""); "#{number}#{ph[:carrier].sms_gateway}"}
  end

  before_validation :lowercase_preferred_phones
  def lowercase_preferred_phones
    (1..4).map{|n| "phone_#{n}_preference".to_sym}.each do |name|
      #if self.send "#{name}_changed?".to_sym
        val = self.send name
        self.send "#{name}=", (val && val.downcase)
      #end
    end
  end

  acts_as_authentic do |c|
    #c.login_field :email
  end

  def phone_order(include_disabled: false, sms_only: false)
    phones = []
    used = {}

    try_phone = lambda { |label|
      unless used[label]
        phone = self.send label
        carrier = self.send "#{label}_carrier".to_sym
        if phone and (include_disabled or !self.send("#{label}_disable")) and (!sms_only or carrier)
          used[label] = true
          phones << {label: label, number: phone, carrier: carrier}
        end
      end
    }

    # First try in preferential order
    (1..4).each do |num|
      pref = "phone_#{num}_preference".to_sym
      if pref_val = self.send(pref)
        label = "#{pref_val}_phone".to_sym
        try_phone.call label
      end
    end

    # Now get all the rest
    PHONE_TYPES.each do |label|
      try_phone.call label
    end

    phones
  end

  def vc_email_url
    "https://volunteerconnection.redcross.org/?nd=email_member&account_id=#{self.vc_id}"
  end

  def vc_profile_url
    "https://volunteerconnection.redcross.org/?nd=vms_profile&account_id=#{self.vc_id}"
  end

  def validate_disabled_phones
    changed_phones = PHONE_TYPES.select{|label| self.send("#{label}_disable_changed?")}
    return unless changed_phones.present?

    present_phones = PHONE_TYPES.select{|label| self.send(label).present? }

    if present_phones.all?{|label| self.send("#{label}_disable") }
      changed_phones.each do |label|
        self.errors["#{label}_disable"] << "At least one phone number must be available for calls."
      end
    end
  end

  def profile_complete?
    [:lat, :lng, :address1, :email].all?{|f| self[f].present?}
  end

  def is_active?
    vc_is_active or has_role 'always_active'
  end
end

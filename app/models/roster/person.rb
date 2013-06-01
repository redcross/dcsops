class Roster::Person < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :primary_county, class_name: 'Roster::County'

  has_many :county_memberships
  has_many :counties, class_name: 'Roster::County', through: :county_memberships

  has_many :position_memberships
  has_many :positions, class_name: 'Roster::Position', through: :position_memberships

  belongs_to :home_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :cell_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :work_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :alternate_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :sms_phone_carrier, class_name: 'Roster::CellCarrier'

  scope :search_name, lambda {|query| where("first_name || ' ' || last_name LIKE ?", "%#{query}%")}
  scope :for_vc_account, lambda {|account| where(vc_id: account).first}

  scope :in_county, lambda {|county| joins(:counties).where(:roster_counties => {id: county})}
  scope :with_position, lambda {|county| joins(:positions).where(:roster_positions => {id: county})}
  scope :by_name, lambda { order(:last_name, :first_name)}

  has_many :shift_assignments, class_name: 'Scheduler::ShiftAssignment'
  has_one :notification_setting, class_name: 'Scheduler::NotificationSetting', foreign_key: 'id'

  validates *((1..4).map{|n| "phone_#{n}_preference".to_sym}), inclusion: {in: %w(home cell work alternate sms), allow_blank: true}
  validates_presence_of :chapter

  validates_inclusion_of :primary_county_id, in: lambda{ |person| person.chapter.county_ids }, allow_nil: true

  default_scope {order(:last_name, :first_name)}

  def primary_county
    super || counties.first
  end

  def primary_county_id
    read_attribute(:primary_county_id) || county_ids.first
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
    c.validate_password_field false
    c.validate_email_field false
    c.validate_login_field false
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
    [:home_phone, :cell_phone, :work_phone, :alternate_phone, :sms_phone].each do |label|
      try_phone.call label
    end

    phones
  end

  def vc_email_url
    "https://volunteerconnection.redcross.org/?nd=email_member&account_id=#{self.vc_id}"
  end
end

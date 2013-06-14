class Roster::Person < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :primary_county, class_name: 'Roster::County'

  has_many :county_memberships, class_name: 'Roster::CountyMembership'
  has_many :counties, class_name: 'Roster::County', through: :county_memberships

  has_many :position_memberships, class_name: 'Roster::PositionMembership'
  has_many :positions, class_name: 'Roster::Position', through: :position_memberships
  has_many :roles, class_name: 'Roster::Role', through: :positions

  belongs_to :home_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :cell_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :work_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :alternate_phone_carrier, class_name: 'Roster::CellCarrier'
  belongs_to :sms_phone_carrier, class_name: 'Roster::CellCarrier'

  scope :name_contains, lambda {|query| 
    where{lower(first_name.op('||', ' ').op('||', last_name)).like("%#{query.downcase}%")}
  }
  scope :for_vc_account, lambda {|account| where(vc_id: account).first}

  scope :in_county, lambda {|county| joins(:counties).where(:roster_counties => {id: county})}
  scope :with_position, lambda {|county| joins(:positions).where(:roster_positions => {id: county})}
  scope :by_name, lambda { order(:last_name, :first_name)}

  has_many :shift_assignments, class_name: 'Scheduler::ShiftAssignment'
  has_one :notification_setting, class_name: 'Scheduler::NotificationSetting', foreign_key: 'id'

  validates *((1..4).map{|n| "phone_#{n}_preference".to_sym}), inclusion: {in: %w(home cell work alternate sms), allow_blank: true}
  validates_presence_of :chapter

  validates_inclusion_of :primary_county_id, in: lambda{ |person| person.chapter.county_ids }, allow_nil: true, allow_blank: true

  default_scope {order(:last_name, :first_name)}

  accepts_nested_attributes_for :county_memberships, :position_memberships, allow_destroy: true

  before_save :geocode_address

  def has_role(grant_name)
    roles.select{|p| p.grant_name == grant_name}.present?
  end

  def scope_for_role(grant_name)
    roles.select{|p| p.grant_name == grant_name}.map(&:role_scope).map{ |scope| scope.include?( :county_ids) ? county_ids : scope}.flatten.compact.uniq
  end

  def primary_county
    super || counties.first
  end

  def primary_county_id
    (read_attribute(:primary_county_id) || county_ids.first)
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

  def geocode_address
    return if Rails.env.test?

    return
    
    if lat.nil? or lng.nil? or (changed & %w(address1 address2 city state zip)).present?
      puts 'geocoding'
      res = Geokit::Geocoders::GoogleV3Geocoder.geocode( [address1, address2, city, state, zip].join(" "))
      if res
        (self.lat, self.lng) = res.lat, res.lng
      end
    end

    return true
  rescue TooManyQueriesError
    self.lat = nil
    self.lng = nil

    return true
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

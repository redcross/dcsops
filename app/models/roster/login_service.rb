class Roster::LoginService

  def initialize(username, password)
    @username = username
    @password = password
  end

  def deferred_update
    # This should be a delayed_job enqueue
    call
  end

  # Returns true/false based on validity of the credentials
  def call
    info = Vc::Login.get_user @username, @password

    update_person_info info
  end

  def update_person_info info
    @person = Roster::Person.find_or_initialize_by(vc_id: info[:vc_id])

    update_new_record if @person.new_record?

    update_credentials
    update_data info
    update_deployments info[:dro_history]
    @person.save!
  end

  def update_new_record
    @person.chapter_id ||= 0
    @person.vc_is_active = false
  end

  def update_credentials
    @person.username = @username
    @person.password = @password
  end

  def update_data info
    @person.attributes = info.slice(:first_name, :last_name, :address1, :address2, :city, :state, :zip, :email, :vc_member_number)
  end

  def update_deployments deployments  

  end
end

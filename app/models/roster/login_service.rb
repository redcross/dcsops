class Roster::LoginService

  def initialize(username, password)
    @username = username
    @password = password
    @ignore_credentials = false
  end

  def deferred_update
    # This should be a delayed_job enqueue
    @ignore_credentials = true
    call
  rescue => e
    Raven.capture e
  end

  # Returns true/false based on validity of the credentials
  def call
    info = Vc::Login.get_user @username, @password

    update_person_info info
  end

  def update_person_info info
    @person = Roster::Person.find_or_initialize_by(vc_id: info[:vc_id])

    update_new_record if @person.new_record?

    update_credentials unless @ignore_credentials
    update_data info
    @person.save!

    update_deployments info[:dro_history]
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
    deployments.each do |deployment|
      disaster = Incidents::Disaster.find_or_create_by(name: deployment[:incident_name])
      dep = Incidents::Deployment.find_or_initialize_by(disaster_id: disaster.id, gap: deployment[:gap], person_id: @person.id)
      dep.date_first_seen = deployment[:assign_date]
      dep.date_last_seen = deployment[:release_date] || Date.current
      dep.save!
    end
  end
end

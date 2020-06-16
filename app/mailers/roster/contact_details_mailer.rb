class Roster::ContactDetailsMailer < ActionMailer::Base
  include MailerCommon
  default from: "DCSOps <scheduling@dcsops.org>"

  def contact_details person
    @person = person
    @region = person.region

    mail to: format_address(person), subject: "DCSOps Welcome and Contact Info Confirmation"
  end

  protected

  def positions
    @person.positions.pluck(:name).flatten.uniq.sort
  end

  def shifts
    Scheduler::Shift.can_be_taken_by(@person).to_a.map{|sh| "#{sh.shift_territory.name} - #{sh.name}"}.uniq.sort
  end

  def events
    Incidents::Notifications::Trigger.joins(role: :positions)
      .where(role: { positions: { id: @person.position_ids } }).includes(:role, :event).map{|t| "#{t.event.name} (#{t.humanized_template})"}.uniq.sort
  end

  def vc_profile_url
    "https://volunteerconnection.redcross.org/?nd=profile_edit"
  end

  def dcsops_profile_url
    roster_person_url(@person)
  end

  helper_method :positions, :shifts, :events, :vc_profile_url, :dcsops_profile_url
end
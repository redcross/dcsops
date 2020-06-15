class Incidents::ResponderMessageService
  include Incidents::ResponderMessagesHelper, ApplicationHelper # to get short_url
  attr_reader :incoming, :response, :assignment, :recruitment

  MessageMatcher = Struct.new(:patterns, :handler)
  ASSIGNMENT_MATCHERS = []
  RECRUITMENT_MATCHERS = []
  def self.assignment_matcher *patterns, &block
    ASSIGNMENT_MATCHERS << MessageMatcher.new(patterns, block)
  end
  def self.recruitment_matcher *patterns, &block
    RECRUITMENT_MATCHERS << MessageMatcher.new(patterns, block)
  end

  def initialize(message, media=[])
    @incoming = message
    @media = media
  end

  def assign_incident inc
    @incident = incoming.incident = response.incident = inc
    @incident = Incidents::IncidentPresenter.new @incident
  end

  def reply
    @response = Incidents::ResponderMessage.new region: incoming.region, person: incoming.person
    incoming.acknowledged = true

    if @assignment = open_assignment_for_person(incoming.person)
      assign_incident assignment.incident
      handle_command incoming.message.downcase, ASSIGNMENT_MATCHERS
      handle_media @media
    elsif @recruitment = open_recruitment_for_person(incoming.person)
      assign_incident recruitment.incident
      handle_command incoming.message.downcase, RECRUITMENT_MATCHERS
    else
      response.message = "You are not currently assigned to an incident response."
    end

    incoming.save
    response
  end

  def handle_media media
    media.each do |m|
      attachment = assignment.incident.attachments.build
      attachment.attachment_type = 'exterior_photo'
      attachment.file = URI.parse(m[:url])
      attachment.name = "Photo from #{incoming.person.full_name}"
      attachment.description = incoming.message.gsub(%r{\s*\[[^\[]*\]$}, '')
      
      # Just report errors through Sentry to see what if anything is going wrong
      begin
        attachment.save!
      rescue => e
        Raven.capture(e)
      end
    end

    publisher.publish_attachments if media.present?
  end

  def open_assignment_for_person(person)
    Incidents::ResponderAssignment.joins(:incident).readonly(false).where{incident.status == 'open'}.was_available.for_person(person).order(created_at: :desc).first
  end

  def open_recruitment_for_person(person)
    Incidents::ResponderRecruitment.joins(:incident).readonly(false).where{incident.status == 'open'}.for_person(person).order(created_at: :desc).first
  end

  def handle_command input, matchers
    matchers.each do |matcher|
      if matcher.patterns.any?{|p| p =~ input}
        return self.instance_exec(&matcher.handler)
      end
    end
    handle_unknown_message
  end

  def handle_unknown_message
    incoming.acknowledged = false
    incoming.save
    publisher.publish_incoming
  end

  recruitment_matcher /^yes/ do
    recruitment.available!
    publisher.publish_recruitment
  end

  recruitment_matcher /^no/ do
    recruitment.unavailable!
    publisher.publish_recruitment
  end

  assignment_matcher /^commands/ do
    response.message = "DCSOps SMS Commands: MAP for map link, RESPONDERS for contact info, ENROUTE when you're on the way, ARRIVED to record you're on scene, DEPARTED to record you've left"
  end

  assignment_matcher /^en ?route/ do
    if !assignment.dispatched_at
      assignment.dispatched!
      response.message = "You're now enroute."
      publisher.publish_responders
    else
      response.message = "You're already enroute."
    end
  end

  assignment_matcher /^on scene/, /^arrived/ do
    if !assignment.on_scene_at
      assignment.on_scene!
      response.message = "You're now on scene."
      publisher.publish_responders
    else
      response.message = "You're already on scene."
    end
  end

  assignment_matcher /^departed/ do
    if !assignment.departed_scene_at && assignment.on_scene_at
      assignment.departed_scene!
      response.message = "You've now departed the scene."
      publisher.publish_responders
    elsif assignment.departed_scene_at
      response.message = "You've already departed the scene."
    else
      response.message = "You aren't on scene yet!"
    end
  end

  assignment_matcher /^map/, /^directions/, /^address/ do
    response.message = map_link_message
  end

  assignment_matcher /^responders/ do
    response.message = responder_info_message(incoming.person)
  end

  assignment_matcher /^incident/ do
    response.message = "Incident #{incident.incident_number} Type: #{incident.humanized_incident_type}.  You are assigned as: #{assignment.humanized_role}"
  end

  def incident
    @incident ||= Incidents::IncidentPresenter.new(assignment.incident)
  end

  def publisher
    @publisher ||= Incidents::UpdatePublisher.new(incident.region, incident)
  end
end

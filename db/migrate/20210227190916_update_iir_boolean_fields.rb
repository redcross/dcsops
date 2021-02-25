class UpdateIirBooleanFields < ActiveRecord::Migration[5.2]
  def up
    add_column :incidents_initial_incident_reports, :significant_media_tmp, :string
    add_column :incidents_initial_incident_reports, :safety_concerns_tmp, :string
    add_column :incidents_initial_incident_reports, :weather_concerns_tmp, :string
    PaperTrail.config.enabled = false
    Incidents::InitialIncidentReport.reset_column_information
    Incidents::InitialIncidentReport.all.each do |iir|
      if iir.significant_media
        iir.significant_media_tmp = "local"
      else
        iir.significant_media_tmp = "no"
      end
      if iir.safety_concerns
        iir.safety_concerns_tmp = "yes"
      else
        iir.safety_concerns_tmp = "no"
      end
      if iir.weather_concerns
        iir.weather_concerns_tmp = "yes"
      else
        iir.weather_concerns_tmp = "no"
      end
      iir.save!(:validate => false)
    end

    remove_column :incidents_initial_incident_reports, :significant_media
    remove_column :incidents_initial_incident_reports, :safety_concerns
    remove_column :incidents_initial_incident_reports, :weather_concerns
    rename_column :incidents_initial_incident_reports, :significant_media_tmp, :significant_media
    rename_column :incidents_initial_incident_reports, :safety_concerns_tmp, :safety_concerns
    rename_column :incidents_initial_incident_reports, :weather_concerns_tmp, :weather_concerns
  end

  def down
    add_column :incidents_initial_incident_reports, :significant_media_tmp, :boolean
    add_column :incidents_initial_incident_reports, :safety_concerns_tmp, :boolean
    add_column :incidents_initial_incident_reports, :weather_concerns_tmp, :boolean
    PaperTrail.config.enabled = false
    Incidents::InitialIncidentReport.reset_column_information
    Incidents::InitialIncidentReport.all.each do |iir|
      if iir.significant_media == "local"
        iir.significant_media_tmp = true
      else
        iir.significant_media_tmp = false
      end
      if iir.safety_concerns == "local"
        iir.safety_concerns_tmp = true
      else
        iir.safety_concerns_tmp = false
      end
      if iir.weather_concerns == "local"
        iir.weather_concerns_tmp = true
      else
        iir.weather_concerns_tmp = false
      end
      iir.save!(:validate => false)
    end

    remove_column :incidents_initial_incident_reports, :significant_media
    remove_column :incidents_initial_incident_reports, :safety_concerns
    remove_column :incidents_initial_incident_reports, :weather_concerns
    rename_column :incidents_initial_incident_reports, :significant_media_tmp, :significant_media
    rename_column :incidents_initial_incident_reports, :safety_concerns_tmp, :safety_concerns
    rename_column :incidents_initial_incident_reports, :weather_concerns_tmp, :weather_concerns
  end
end

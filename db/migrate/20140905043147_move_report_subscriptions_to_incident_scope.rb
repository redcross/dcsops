class MoveReportSubscriptionsToIncidentScope < ActiveRecord::Migration
  def change
    say_with_time 'Moving report config' do
      Roster::Chapter.where.not(id: 0).each do |chapter|
        scope = Incidents::Scope.for_chapter chapter
        scope.report_frequencies = chapter.config.delete 'incidents_enabled_report_frequencies'
        scope.report_send_at = chapter.config.delete 'incidents_report_send_at'
        scope.report_send_automatically = chapter.config.delete 'incidents_report_send_automatically'
        scope.report_include_assistance_amounts = chapter.config.delete 'incidents_report_include_assistance_amounts'
        scope.save!
        chapter.save!
      end
    end

    add_column :incidents_report_subscriptions, :scope_id, :integer

    say_with_time 'Update scope_id in report subscriptions' do
      Incidents::ReportSubscription.includes(:person).find_each do |sub|
        sub.update_attribute :scope_id, Incidents::Scope.for_chapter(sub.person.chapter_id)
      end
    end
  end
end

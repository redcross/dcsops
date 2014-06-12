module Admin
  module Views
    class LogStatusIndex < ActiveAdmin::Component

      def latest_logs
        latest_ids = ImportLog.select{[controller, name, max(id).as(id)]}.group{[controller, name]}.where{created_at > 1.month.ago}.to_a
        run_counts = ImportLog.select{[controller, name, count(id).as(:count)]}.group{[controller, name]}.where{created_at > 1.month.ago}.group_by{|r| [r.controller, r.name]}
        latest_logs = ImportLog.where{id.in(latest_ids)}.order{[controller, name]}.group_by(&:controller)
      end

      def headers
        tr do
          th "Controller", colspan: 3
          th "Status", colspan: 2
          th colspan: 1
          th "Most Recent Run", colspan: 2
        end
        tr do
          th
          th "ID"
          th "Name"
          th "Result"
          th "# Rows"
          th "Runtime"
          th "Most Recent Run", colspan: 2
        end
      end

      def group_row controller, group
        total = group.count
        last_run = group.map(&:created_at).max
        success = group.count{|log| log.result == 'success' }
        state = (total == success) ? 'success' : 'error'
        tbody class: 'controller-group' do
          tr class: 'even' do
            td colspan: 3 do
              link_to controller, {q: {controller_eq: controller}}
            end
            td state
            td "#{success}/#{total}"
            td
            td last_run.to_s(:date_time)
            td time_ago_in_words(last_run, include_seconds: false)
          end
        end
      end

      def format_duration dur
        dur.present? && ("%0.1fs" % dur)
      end

      def status_row log
        tr class: 'odd' do
          td
          td do
            link_to log.id, [:scheduler_admin, log]
          end
          td do
            link_to log.name, {q: {controller_eq: log.controller, name_eq: log.name}}
          end
          #td run_counts[[log.controller, log.name]].try(:count)
          td log.result
          td log.num_rows
          #td log.exception_message
          td format_duration(log.runtime)
          td log.created_at.to_s(:date_time)
          td time_ago_in_words(log.created_at, include_seconds: false)
        end
      end

      def build(page_presenter, collection_unused)
        table class: "index_table" do
          thead do
            headers
          end
          latest_logs.each do |controller, group|
            group_row(controller, group)
            tbody class: 'row-group' do
              group.each do |log|
                status_row(log)
              end
            end
          end
        end
      end

      def self.index_name
        "log_status"
      end

    end
  end
end

module Admin
  module Views
    class LogStatusIndex < ActiveAdmin::Component
      #run_counts = base.select{[controller, name, count(id).as(:count)]}.group{[controller, name]}.group_by{|r| [r.controller, r.name]}

      def base
         ImportLog.where{created_at > 1.month.ago}
       end

      def latest_ids
        base.select{[controller, name, max(id).as('id')]}.group{[controller, name]}.to_a
      end

      def latest_logs
        latest_logs = ImportLog.where{id.in(my{latest_ids})}.order{[controller, name]}.group_by(&:controller)
      end

      def headers
        tr do
          th "Controller", colspan: 3
          th "Status", colspan: 3
          th "Most Recent Run", colspan: 2, rowspan: 2
        end
        tr do
          th
          th "ID"
          th "Name"
          th "Result"
          th "# Rows"
          th "Runtime"
        end
      end

      def group_row controller, group
        total = group.count
        last_run = group.map(&:created_at).min
        success = group.count{|log| log.result == 'success' }
        state = (total == success) ? 'success' : 'error'

        tbody class: 'controller-group' do
          tr class: 'even' do
            td colspan: 3 do
              controller_link controller
            end
            td state
            td "#{success}/#{total}"
            td
            td last_run.to_s(:date_time)
            td format_time(last_run)
          end
        end
      end

      def format_duration dur
        dur.present? && ("%0.1fs" % dur)
      end

      def format_time time
        time_ago_in_words(time, include_seconds: false)
      end

      def controller_link controller
        link_to controller, {q: {controller_eq: controller}, as: 'table'}
      end

      def action_link log
        link_to log.name, {q: {controller_eq: log.controller, name_eq: log.name}, as: 'table'}
      end

      def status_row log
        tr class: 'odd' do
          td
          td link_to(log.id, resource_path(log))
          td action_link(log)
          td log.result
          td log.num_rows
          td format_duration(log.runtime)
          td log.created_at.to_s(:date_time)
          td format_time(log.created_at)
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

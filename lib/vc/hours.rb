module Vc
  class Hours

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def xml_token
      resp = client.get '/', query: {nd: 'vms_hours_add_admin'}
      body = Nokogiri::HTML(resp)
      {xmlhttp_token: body.css('#xmlhttp_token').attr('value'),
       hierarchy_id: body.css('#hierarchy_id').attr('value')}
    end

    def submit_hours account_id, description, number_of_hours, hours_type: 'oncall', status: 'approved', date: Date.current, comments: nil, admin_comments: nil
      raise ArgumentError, "Not a valid hours_type: #{hours_type}" unless %w(oncall worked).include? hours_type
      raise ArgumentError, "Not a valid status: #{status}" unless %w(rejected pending approved).include? status

      hours_type = hours_type.titleize
      status = status.titleize

      args = {
        nd: 'xmlhttp-vms_calendar_hours_submission_save',
        action: 'hours_submission_save',
        dosave: 1,
        group_id: '',
        sku: '',

        account_id: account_id,
        activity_name: description,
        activity_datetime: date.to_s,
        activity_type: hours_type,
        activity_program: '',
        activity_reference: '',
        status_lookup: status,
        comments: comments,
        admin_comments: admin_comments,
        hours_worked: ("%.02f" % number_of_hours.to_f)
      }.merge(xml_token)

      resp = client.post '', body: args
    end
  end
end
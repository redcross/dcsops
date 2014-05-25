class window.EventLogsController
  constructor: () ->
    $(document).on 'edit-panel:success', () =>
      $.ajax
        url: window.location.href
        data:
          partial: 'table'
        success: (data, status, xhr) =>
          $('.event-logs-table').html(data)

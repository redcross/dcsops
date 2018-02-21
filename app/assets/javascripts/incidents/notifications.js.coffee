class window.IncidentNotificationsController
  constructor: () ->
    $(document).on 'click', 'a.show-recipients', (evt) =>
      this.showRecipients()
      evt.preventDefault()

    $(document).on 'change', '[id$=event_id]', (evt) =>
      this.reset()

  showRecipients: () ->
    event = $('[id$=event_id]').val()
    url = $('.modal-body.send-notifications a.show-recipients').data('recipients-url')
    return unless event? and event != ''
    $.ajax
      method: 'GET'
      url: url
      data:
        event_id: event
      success: (data, status, xhr) =>
        $('.message-recipients').html(data)

  reset: () ->
    $('.message-recipients').html('')
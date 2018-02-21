class window.ResponderMessagesController
  constructor: () ->
    $(document).on 'change', 'input[name=message_type]', (evt) =>
      msg = $('input[name=message_type]:checked').data('message')
      this.setMessage(msg)
    $(document).on 'keypress', 'textarea[id$=message]', (evt) =>
      this.updateCharacters()

  setMessage: (message) ->
    $('[id$=message]').val(message)
    this.updateCharacters()

  reset: () ->
    this.updateCharacters()

  updateCharacters: () ->
    str = $('textarea[id$=message]').val()
    $('.num-characters').text(str.length)

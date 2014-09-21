class window.IncidentInstantController
  constructor: (@pubnub, @channelName) ->
    @pubnub.subscribe
      channel: @channelName
      message: (msg) => @handleMessage(msg)

  setIncident: (@incidentNumber) ->

  setChapter: (@chapterNumber) ->

  handleMessage: (msg) ->
    console.log msg

    unless msg.chapter == @chapterNumber || (@incidentNumber? && msg.incident == @incidentNumber)
      return
    
    values = msg.refresh

    values.forEach (value, idx) =>
      console.log value
      $targets = $("[data-refresh-name~=\"#{value}\"]")
      $targets.each (idx, target) =>
        path = $(target).data('refresh')
        return unless path
        $.ajax
          url: path
          method: 'GET'
          success: (data, status, xhr) =>
            $(target).html(data)

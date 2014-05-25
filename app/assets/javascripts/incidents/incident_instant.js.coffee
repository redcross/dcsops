class window.IncidentInstantController
  constructor: (@connectionPromise) ->

  monitorRoom: (incidentRoomName) ->
    @connectionPromise.then( (result) => @connection = result.connection; @incidentRoom = @connection.room(incidentRoomName); @incidentRoom.join())
                      .then( (result) => channel = result.room.channel('updates'); channel.on('message', ((value, context)=>@handleUpdate(value,context))) )
                      .catch( (error) -> console.log "error", error )

  setIncident: (@incidentNumber) ->

  handleUpdate: (value, context) ->
    values = value.refresh
    console.log value
    return unless values?
    return if @incidentNumber? && @incidentNumber != value.incident
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


  startChat: (roomName) ->
    @connectionPromise.then( (result) => result.connection.room(roomName).join() )
                      .then( (result) => @chat = new goinstant.widgets.Chat({room: result.room, messageExpiry: (6*60*60), collapsed: true}))
                      .then( (chat) => chat.initialize((err) => console.error err if err?) )
                      .catch( (error) -> console.log "chat error", error)
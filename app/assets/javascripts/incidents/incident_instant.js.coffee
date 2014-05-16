class window.IncidentInstantController
  constructor: (@connectionPromise) ->

  monitorIncident: (incidentRoomName) ->
    @connectionPromise.then( (result) => @connection = result.connection; @incidentRoom = @connection.room(incidentRoomName); @incidentRoom.join())
                      .then( (result) => channel = result.room.channel('updates'); channel.on('message', ((value, context)=>@handleIncidentUpdate(value,context))) )
                      .catch( (error) -> console.log "error", error )

  monitorChapter: (@chapterRoomName) ->

  handleIncidentUpdate: (value, context) ->
    if value.name == 'messages-table'
      $('.incoming-table').html(value.html)
    else if value.name == 'assigned-table'
      $('.assigned-table').html(value.html)

  startChat: (roomName) ->
    @connectionPromise.then( (result) => result.connection.room(roomName).join() )
                      .then( (result) => @chat = new goinstant.widgets.Chat({room: result.room, messageExpiry: (6*60*60), collapsed: true}))
                      .then( (chat) => chat.initialize((err) => console.info err) )
                      .catch( (error) -> console.log "chat error", error)
class window.AttachmentsDragAndDropController
  constructor: (@attachmentCreateUrl) ->
    console.log 'init'
    $(document).bind 'dragenter, dragover', (evt) =>
      this.setDrag(true)
      evt.preventDefault()
    $(document).bind 'dragleave', (evt) =>
      this.setDrag(false)
    $(document).on 'drop', (e) =>
      this.setDrag(false)
      e.preventDefault()
      this.handleDrop(e)

  acceptDrop: (evt) ->
    console.log evt.type, evt.dataTransfer
    evt.dataTransfer.files.length > 0

  setDrag: (val) ->
    $('body').toggleClass 'drag-hover', val

  handleDrop: (evt) ->
    file = evt.originalEvent.dataTransfer.files[0]

    return unless file?

    data = new FormData()
    data.append("incidents_attachment[name]", file.name)
    data.append("incidents_attachment[file]", file)
    data.append("incidents_attachment[attachment_type]", "file")

    $.ajax
      url: @attachmentCreateUrl
      data: data
      type: 'post'
      processData: false
      contentType: false
      success: (data, status, xhr) =>
        console.log data, status, xhr
        $('a[data-toggle=tab][data-target=#inc-attachments]').tab('show')

    



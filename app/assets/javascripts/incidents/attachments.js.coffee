class window.AttachmentsDragAndDropController
  constructor: (@attachmentCreateUrl) ->
    console.log 'init'
    $(document).bind 'dragenter, dragover', (evt) =>
      this.setDrag(true)
      evt.preventDefault()
      return false
    $(document).bind 'dragleave', (evt) =>
      console.log evt.relatedTarget
      this.setDrag(false)
    $(document).on 'drop', (e) =>
      this.setDrag(false)
      e.preventDefault()
      console.log 'drop!'
      this.handleDrop(e)
      return false

  setDrag: (val) ->
    $('body').toggleClass 'drag-hover', val

  handleDrop: (evt) ->
    file = evt.originalEvent.dataTransfer.files[0]

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

    



class window.IncidentEditPanelController

  constructor: () ->
    $(document).on 'click', '[data-toggle=tab]', (evt) =>
      evt.preventDefault()
      evt.stopPropagation()
      false

    $(document).on 'click', 'a.edit-panel', (evt) =>
      evt.preventDefault()
      panel = $(evt.target).attr('href')
      this.openPanel(panel)

    $(document).on 'click', '[data-edit-panel]', (evt) =>
      evt.preventDefault()
      panel = $(evt.target).data('edit-panel')
      this.openPanel(panel)

    $(document).on 'edit-panel:success', (evt, panels) =>
      console.log(panels);
      panels = [].concat(panels);
      $('#edit-modal').modal('hide');
      console.log(panels);
      panels.forEach (panel) =>
        this.updateTab(panel)
      if $('#inc-changes').length > 0
        this.updateTab('changes')

  modalPrepend: '<div class="modal-dialog"><div class="modal-content"><div class="modal-body">'
  modalAppend: '</div></div></div>'

  loadingHtml: '<i class="fa fa-spinner fa-spin"></i> Loading…'
  errorHtml: '<span class="text-danger">An error occurred: <span class="error-value"></span>.  Please try again.<a class="close" data-dismiss="modal">&times;</a>'

  modalContent: (body) ->
    @modalPrepend + body + @modalAppend

  openPanel: (url, callback) ->
    modal = $('#edit-modal')
    modal.html(this.modalContent(this.loadingHtml))
    modal.modal({show: true, keyboard: false})
    $.ajax
      url: url
      dataType: 'html'
      success: (data, status, xhr) ->
        modal.html(data)
        modal.find('legend').remove()
        if callback
          callback(modal)
      error: (xhr, status, error) =>
        wrapper = $(this.modalContent(this.errorHtml))
        wrapper.find(".error-value").text(error)
        modal.html("")
        modal.append(wrapper)


  updateTab: (value) ->
    $targets = $("[data-refresh-name~=\"#{value}\"]")
    console.log $targets
    $targets.each (idx, target) =>
      path = $(target).data('refresh')
      return unless path
      $.ajax
        url: path
        method: 'GET'
        success: (data, status, xhr) =>
          $(target).html(data)
        error: (xhr, status, error) ->
          console.log status, error

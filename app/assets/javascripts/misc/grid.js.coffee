class window.GridController
  constructor: (@baseUrl, @template)->
    @seq = 1
    $(document).on 'click', 'input[type=submit]', (evt) =>
      el = evt.target
      data = {}
      parent = $(el).closest("tr")
      this.submitForm(parent)
    $(document).on 'change', 'input', (evt) =>
      $(evt.target).closest("tr").removeClass().addClass("warning")
    $(document).on 'click', '.add-row', (evt) =>
      this.addRow()
      

  submitForm: (parent) ->
    id = $(parent).data('resource-id')
    data = {}
    $(parent).find("input:not([type=checkbox]), input:checked, select").each (idx, el) =>
      name = $(el).attr('name')
      val = $(el).val()
      if name.match /\[\]$/
        data[name] ||= []
        data[name].push val
      else
        data[name] = val

    console.log data

    $(parent).find("input, select").attr("disabled", "disabled")

    if $(parent).data('is-new')
      submitUrl = @baseUrl + '.js'
      method = 'POST'
    else
      submitUrl = @baseUrl + '/' + id + '.js'
      method = 'PUT'
    console.log submitUrl

    $.ajax
      url: submitUrl
      method: method
      data: data
      accept: "text/javascript"


  addRow: () ->
    dom = $(@template)
    id = "New"+(@seq += 1)
    $(dom).attr('data-resource-id', id).data('is-new', true)
    $(dom).find('input[name=row_id]').val(id)
    $('table.table-edit-grid tbody').append(dom)

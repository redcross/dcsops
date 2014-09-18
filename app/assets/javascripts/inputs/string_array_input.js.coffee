class window.StringArrayController
  constructor: () ->
    $(document).on 'keyup', '[data-string-array] input', (evt) =>
      wrapper = $(evt.target).parents "[data-string-array]"
      $inputs = $(wrapper).find 'input'
      blanks = $.grep $inputs, (el) -> $(el).val().length == 0
      if blanks.length == 0
        tmpl = $(wrapper).data('string-array-template')
        $tmpl = $(tmpl)
        $(wrapper).append($(tmpl))
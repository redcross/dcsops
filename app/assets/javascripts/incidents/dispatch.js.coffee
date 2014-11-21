class window.DispatchController
  constructor: () ->
    $(document).on 'click', '.complete-button', (evt) =>
      evt.preventDefault();
      $target = $(evt.target)
      $target.closest("form").attr("action", $target.data('form-action')).submit()
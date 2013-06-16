# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('.sandbox-dialog button').click (evt) ->
    el = $(evt.target).closest(".sandbox-dialog")
    console.log el
    cookie_name = $(el).data('cookie-code')
    cookie_val = $(el).data('cookie-value')
    cookie_end = $(el).data('cookie-end')
    console.log cookie_name, cookie_val, cookie_end

    document.cookie = "-motd-#{cookie_name}=#{cookie_val};expires=#{cookie_end};path=/"
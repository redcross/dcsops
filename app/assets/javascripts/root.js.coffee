# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ () ->
  el = $('.countdown-container')
  el.countdown
    date: el.data('date')
    render: (date) ->
      $(el).html "#{date.days} days, #{@leadingZeros date.hours} hours, #{@leadingZeros date.min} min and #{@leadingZeros date.sec} sec"
      dest_date = new Date(el.data('date'))
      now = new Date()
      percentage = 1 - ((dest_date.getTime() - now.getTime()) / (7 * 86400 * 1000))
      $(el).parents(".alert").find(".progress .bar").width("#{percentage*100}%")
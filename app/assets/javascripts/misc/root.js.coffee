# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Modernizr.addTest 'webkit', () ->
  return RegExp(" AppleWebKit/").test(navigator.userAgent);

Modernizr.addTest 'mobile', () ->
  return RegExp(" Mobile/").test(navigator.userAgent);

$ () ->
  $('.modal').on 'shown', () ->
    offset = $(this).offset().top
    current = $(window).scrollTop()
    if current > offset
      $(window).scrollTop(offset);
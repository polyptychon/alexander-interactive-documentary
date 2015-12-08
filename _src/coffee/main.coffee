global.$ = global.jQuery = $ = require "jquery"

require "select2"
require "bootstrap/assets/javascripts/bootstrap/transition"
require "bootstrap/assets/javascripts/bootstrap/affix"
require "bootstrap/assets/javascripts/bootstrap/tab"
require "bootstrap/assets/javascripts/bootstrap/dropdown"
require "bootstrap/assets/javascripts/bootstrap/collapse"
require "bootstrap/assets/javascripts/bootstrap/carousel"
require "./player-animation.coffee"

isTouchDevice =  require "./detectTouchDevice"
$('html').addClass('hasTouch') if isTouchDevice()



$('.btn.next').bind('click', ()->
   $('.related-videos-container').removeClass('page1')
   $('.related-videos-container').addClass('page2')
)
$('.btn.previous').bind('click', ()->
  $('.related-videos-container').removeClass('page2')
  $('.related-videos-container').addClass('page1')
)

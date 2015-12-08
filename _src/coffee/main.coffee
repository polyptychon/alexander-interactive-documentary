global.$ = global.jQuery = $ = require "jquery"

require "select2"
require "bootstrap/assets/javascripts/bootstrap/transition"
require "bootstrap/assets/javascripts/bootstrap/affix"
require "bootstrap/assets/javascripts/bootstrap/tab"
require "bootstrap/assets/javascripts/bootstrap/dropdown"
require "bootstrap/assets/javascripts/bootstrap/collapse"
require "bootstrap/assets/javascripts/bootstrap/carousel"

isTouchDevice =  require "./detectTouchDevice"
$('html').addClass('hasTouch') if isTouchDevice()

require "./preload-assets.coffee"
require "./player-animation.coffee"
require "./archive-animation.coffee"

$('.dropdown-menu-btn').bind('click', ()->
  $(this).closest('.dropdown-menu').toggleClass('visible')
  $(this).find('.dropdown-menu').toggleClass('visible')
  $(this).parent().find('.dropdown-menu').toggleClass('visible')
)

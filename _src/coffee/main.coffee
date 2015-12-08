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

require "./player-animation.coffee"
require "./archive-animation.coffee"

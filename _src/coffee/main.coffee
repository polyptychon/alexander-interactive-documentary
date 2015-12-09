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

displayPage = require "./displayPage.coffee"
play = require "./play.coffee"
handleLoadComplete = ()-> displayPage('.landing', queue.getItem("landing-bg").src, '')

$('.play-documentary-btn').bind('click', ()->
  play(1, 0, queue.getItem("chapter-1-bg").src)
)
$('.btn-footer.btn-home').bind('click', ()->
  displayPage('.landing', queue.getItem("landing-bg").src)
)
queue = require("./preload-assets.coffee")(handleLoadComplete)

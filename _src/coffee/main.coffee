global.$ = global.jQuery = $ = require "jquery"

isTouchDevice =  require "./detectTouchDevice"
$('html').addClass('hasTouch') if isTouchDevice()

require "./player-animation.coffee"
require "./archive-animation.coffee"

displayPage = require "./displayPage.coffee"
player = require "./play.coffee"
handleLoadComplete = ()-> displayPage('.landing', queue.getItem("landing-bg").src, '')

$('.play-documentary-btn').bind('click', ()->
  player.stop()
  player.play(1, 0, queue.getItem("chapter-1-bg").src)
)
$('.btn-footer.btn-home, .archive .back').bind('click', ()->
  player.stop()
  displayPage('.landing', queue.getItem("landing-bg").src)
)
$('.archive-btn').bind('click', ()->
  displayPage('.archive', queue.getItem("stoneDark").src)
)
queue = require("./preload-assets.coffee")(handleLoadComplete)

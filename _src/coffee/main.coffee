global.$ = global.jQuery = $ = require "jquery"

isTouchDevice =  require "./detectTouchDevice"
$('html').addClass('hasTouch') if isTouchDevice()

require "./player-animation.coffee"
require "./SoundWrapper"

resetArchive = require "./archive-animation.coffee"
displayPage = require "./displayPage.coffee"
player = require "./play.coffee"
play = require "play-audio"

handleLoadComplete = ()->
  displayPage('.landing', queue.getItem("landing-bg").src, '')
  SM.playMusic('music', -1, 3000)

$('.play-documentary-btn').bind('click', ()->
  player.stop()
  player.play(1, 0, queue.getItem("chapter-1-bg").src)
)
$('.btn-footer.btn-home').bind('click', ()->
  player.stop()
  if ($('.page.visible').hasClass('archive'))
    $('.archive .back').trigger('click')
  else
    displayPage('.landing', queue.getItem("landing-bg").src)
)
$('.archive-btn').bind('click', ()->
  displayPage('.archive', queue.getItem("stoneDark").src)
  createjs.Sound.play("page-slide-up");
)
$('.archive .back').bind('click', ()->
  resetArchive()
  displayPage('.landing', queue.getItem("landing-bg").src, '')
  createjs.Sound.play("page-slide-back");
)
$('.chapters li a, .intro-buttons a, .related-videos a').bind('mouseover', ()->
  createjs.Sound.play("over");
)
$('.chapters li a, .intro-buttons a, .related-videos a').bind('click', ()->
  createjs.Sound.play("click");
)
queue = require("./preload-assets.coffee")(handleLoadComplete)

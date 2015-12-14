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
  $('.landing').find('.bg').css('background-image', "url(#{queue.getItem("landing-bg").src})")
  $('.archive').find('.bg').css('background-image', "url(#{queue.getItem("stoneDark").src})")
  $('.video-player').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  displayPage('.landing', '')
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
    displayPage('.landing')
)
$('.archive-btn').bind('click', ()->
  displayPage('.archive')
  createjs.Sound.play("page-slide-up")
)
$('.archive .back').bind('click', ()->
  resetArchive()
  displayPage('.landing', '')
  createjs.Sound.play("page-slide-back")
)
$('.chapters li a, .intro-buttons a, .related-videos a').bind('mouseover', ()->
  createjs.Sound.play("over")
)
$('.chapters li a, .intro-buttons a, .related-videos a').bind('click', ()->
  createjs.Sound.play("click")
)
$('.related-videos a').bind('click', ()->
  displayPage('.video-player-compact', '')
)
$('.video-player-compact .back').bind('click', ()->
  displayPage('.archive', '')
  createjs.Sound.play("page-slide-back")
)
queue = require("./preload-assets.coffee")(handleLoadComplete)

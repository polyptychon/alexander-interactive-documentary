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
  $('.chapter').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  $('.video-player').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  $('.video-player-compact').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  displayPage('.landing', '')
  SM.playMusic('music', -1, 3000)

$('.play-documentary-btn').bind('click', ()->
  player.stop()
  player.play(1, 0)
)
$('.btn-footer.btn-home').bind('click', ()->
  $('body').removeClass('show-chapters')
  $('.page').removeClass('slide-up').removeClass('slide-down')
  player.stop()
  if ($('.page.visible').hasClass('archive'))
    $('.archive .back').trigger('click')
  else
    displayPage('.landing', '')
)
$('.chapters-btn').bind('click', (e)->
  $('body').toggleClass('show-chapters')
)
$('.chapters .back').bind('click', (e)->
  $('body').toggleClass('show-chapters')
)
$('.archive-btn').bind('click', ()->
  displayPage('.archive')
  createjs.Sound.play("page-slide-up")
)
$('.archive .back').bind('click', ()->
  $('.archive').removeClass('slide-up')
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
$('.archive .related-videos a').bind('click', ()->
  $('.page.visible').addClass('slide-up')
  $('.video-player-compact').addClass('slide-down')
  SM.stopMusic('music', 6000)
  displayPage('.video-player-compact', '')
)
$('.video-player-compact .back').bind('click', ()->
  displayPage('.archive', '')
  createjs.Sound.play("page-slide-back")
  SM.playMusic('music', -1, 0)
)
queue = require("./preload-assets.coffee")(handleLoadComplete)

global.$ = global.jQuery = $ = require "jquery"

isTouchDevice =  require "./detectTouchDevice"
$('html').addClass('hasTouch') if isTouchDevice()
requestAnimFrame = require "animationframe"
queue = require "./preload-assets.coffee"
require "./player-timer.coffee"
require "./SoundWrapper"

resetArchive = require "./archive-animation.coffee"
chapterManager = require "./chapters.coffee"
displayPage = require "./displayPage.coffee"
player = require "./play.coffee"
ls = require 'local-storage'
play = require "play-audio"

init = ()->
  chapterContainers = $('.chapters-container ul, .player-footer-container .chapters ul')
  chapterList = ""
  chapterManager.chapters.forEach((item, index)->
    chapterList += "<li><a href=\"javascript:\">#{index+1} - #{item.title}</a></li>"
  )
  chapterContainers.html(chapterList)

  $('body').addClass('show-subtitles') if ls.get(chapterManager.LOCAL_STORAGE_SHOW_SUBTITLES)
  player.setVideoSource(chapterManager.getCurrentChapterSource(), $('.video'))

  chapterContainers.find('a').bind('click', ()->
    $('body').removeClass('show-chapters')
    player.stop()
    chapterManager.setCurrentChapterPlaying($(this).parent().index())
    player.play(chapterManager.getCurrentChapterSource())
  )
  queue = queue(handleLoadComplete)

handleLoadComplete = ()->
  $('.landing').find('.bg').css('background-image', "url(#{queue.getItem("landing-bg").src})")
  $('.archive').find('.bg').css('background-image', "url(#{queue.getItem("stoneDark").src})")
  $('.chapter').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  $('.video-player').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  $('.video-player-compact').find('.bg').css('background-image', "url(#{queue.getItem("chapter-1-bg").src})")
  displayPage('.landing', '')
  SM.playMusic('music', -1, 1000)

resetPageAnimation = (callback)->
  $('.page').css('transitionDuration', '0ms');
  $('.page').removeClass('slide-up').removeClass('slide-down')
  requestAnimFrame(()->
    requestAnimFrame(()->
      $('.page').css('transitionDuration', '500ms');
      callback()
    )
  )

$('.play-documentary-btn').bind('click', ()->
  player.stop()
  chapterManager.setCurrentChapterPlaying(0)
  player.play(chapterManager.getCurrentChapterSource())
)
$('.resume-documentary-btn').bind('click', ()->
  player.stop()
  chapterManager.setCurrentChapterPlaying(ls.get(chapterManager.LOCAL_STORAGE_CHAPTER))
  player.play(chapterManager.getCurrentChapterSource(),ls.get(chapterManager.LOCAL_STORAGE_TIME))
)
$('.btn-footer.btn-home').bind('click', ()->
  $('body').removeClass('show-chapters')
  resetPageAnimation(()->
    player.stop()
    if ($('.page.visible').hasClass('archive'))
      $('.archive .back').trigger('click')
    else
      displayPage('.landing', '')
  )
)
$('.chapters-btn').bind('click', ()->
  $('body').toggleClass('show-chapters')
  $('.info-popup').addClass('hidden')
)
$('.chapters .back').bind('click', ()->
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
  SM.stopMusic('music', 1000)
  displayPage('.video-player-compact', '')
  createjs.Sound.play("page-slide-up")
  player.playVideo(chapterManager.getCurrentChapterSource())
)
$('.video-player-compact .back').bind('click', ()->
  displayPage('.archive', '')
  SM.playMusic('music', -1, 0)
  createjs.Sound.play("page-slide-back")
  player.stop()
)
$('.video-player-compact-documentary .back').bind('click', ()->
  player.stop()
  displayPage('.video-player', '')
  createjs.Sound.play("page-slide-back")
  player.resumeVideo()
)
$('.related-items-btn').bind('click', ()->
  $('.info-popup').addClass('hidden')
  $('body').removeClass('show-chapters')
  $('.player-footer-container').toggleClass('open-related-items')
)

init()

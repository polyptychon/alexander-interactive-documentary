requestAnimFrame = require("animationframe")
displayPage = require "./displayPage.coffee"
require "./SoundWrapper"

pageTimeoutId = -1
currentVideo = $('.page.video-player .video video')[0]
progressBarContainer = $('.page.video-player .progress-bar-container')
progressBar = $('.page.video-player .bar-progress')
durationInfo = $('.page.video-player .container.info-container .duration-info')

module.exports = {
  play: (chapter, time=0, chapterBg=null)->
    clearTimeout(pageTimeoutId)
    displayPage('.chapter', 'cross-dissolve', chapterBg)
    $('.player-footer-container').addClass('mini')
    currentVideo.currentTime = time
    pageTimeoutId = setTimeout(()->
      SM.stopMusic('music', 6000)
      $('body').addClass('is-playing')
      $('.player-footer-container').removeClass('mini')
      displayPage('.video-player')
      currentVideo.play()
    , 4000)
  stop: ()->
    currentVideo.pause() if currentVideo
    clearTimeout(pageTimeoutId)
    $('body').removeClass('is-playing')
    SM.playMusic('music', -1, 3000)
}
formatTime = (totalSec)->
  hours = parseInt( totalSec / 3600 ) % 24
  minutes = parseInt( totalSec / 60 ) % 60
  seconds = Math.ceil(totalSec % 60);
  if hours>0
    result = (if hours < 10 then "0" + hours else hours) + ":" + (if minutes < 10 then "0" + minutes else minutes) + ":" + (if seconds  < 10 then "0" + seconds else seconds)
  else
    result = (if minutes < 10 then  "0" + minutes else minutes) + ":" + (if seconds  < 10 then "0" + seconds else seconds)
  return result

updateProgressBar = ()->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  currentTime = if !currentVideo? || isNaN(currentVideo.currentTime) then 0 else currentVideo.currentTime
  progress = currentTime/duration * 100

  progressBar.css('transition-duration', "16ms")
  progressBar.css('width', "#{progress}%")
  durationInfo.html("#{formatTime(currentTime)} | #{formatTime(duration)}")

$(currentVideo).bind('ended', ()->
  console.log 'ended...'
)
$(currentVideo).bind('play', ()->
  updateProgress = ()->
    requestAnimFrame(()->
      updateProgressBar()
      updateProgress() if !currentVideo.paused
    )
  updateProgress()
)
$(currentVideo).bind('ended', ()->
  console.log 'ended...'
)
updateTime = (x)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  position = (x) / progressBarContainer.width()
  currentVideo.currentTime = duration * position

mouseMoveHandler = (e)->
  updateTime(e.clientX-progressBarContainer.offset().left-30)
  updateProgressBar()
  e.stopImmediatePropagation()
  return false

stopUpdateTime = ()->
  progressBarContainer.unbind('mouseup')
  $(window).unbind('mousemove').unbind('mouseup')
  currentVideo.play()

progressBarContainer.bind('mousedown', (e)->
  currentVideo.pause()
  updateTime(e.clientX-progressBarContainer.offset().left-30)
  updateProgressBar()
  $(window).unbind('mousemove').bind('mousemove', mouseMoveHandler).bind('mouseup', stopUpdateTime)
  progressBarContainer.unbind('mouseup').bind('mouseup', stopUpdateTime)
)


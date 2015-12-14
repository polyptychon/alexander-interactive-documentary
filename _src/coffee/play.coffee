requestAnimFrame = require("animationframe")
displayPage = require "./displayPage.coffee"
video = require("media").video
require "./SoundWrapper"

pageTimeoutId = -1
videoItem = video('http://jfk.s3.amazonaws.com/chapters/ch1.webm?bust=0', $('.page.video-player .video')[0])
currentVideo = videoItem.element()
progressBarContainer = $('.page.video-player .progress-bar-container')
progressBar = $('.page.video-player .bar-progress')
durationInfo = $('.page.video-player .container.info-container .duration-info')

module.exports = {
  play: (chapter, time=0, chapterBg=null)->
    clearTimeout(pageTimeoutId)
    displayPage('.chapter', 'cross-dissolve', chapterBg)
    $('.player-footer-container').addClass('mini')
    pageTimeoutId = setTimeout(()->
      SM.stopMusic('music', 6000)
      $('body').addClass('is-playing')
      $('.player-footer-container').removeClass('mini')
      displayPage('.video-player')
      currentVideo.play()
      currentVideo.currentTime = time
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

videoItem.on('play', ()->
  updateProgress = ()->
    requestAnimFrame(()->
      updateProgressBar()
      updateProgress() if !currentVideo.paused
    )
  updateProgress()
)
videoItem.on('ended', (e)->

)
updateTime = (x)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  position = (x) / progressBarContainer.width()
  currentVideo.currentTime = duration * position

mouseMoveHandler = (e)->
  updateTime(e.clientX-144)
  updateProgressBar()
  e.stopImmediatePropagation()
  return false

progressBarContainer.bind('mousedown', (e)->
  currentVideo.pause()
  updateTime(e.offsetX)
  updateProgressBar()
  $(window).unbind('mousemove').bind('mousemove', mouseMoveHandler)
)
progressBarContainer.bind('mouseup', (e)->
  $(window).unbind('mousemove')
  currentVideo.play()
)

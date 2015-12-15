requestAnimFrame = require("animationframe")
displayPage = require "./displayPage.coffee"
require "./SoundWrapper"

pageTimeoutId = -1
currentVideo = null
progressBarContainer = null
progressBar = null
durationInfo = null
infoPopup = null

setVideoControls = (parent)->
  currentVideo = parent.find('.video video')[0]
  progressBarContainer = parent.find('.progress-bar-container')
  progressBar = parent.find('.bar-progress')
  durationInfo = parent.find('.duration-info')
  infoPopup = parent.find('.info-popup')

setVideoControls($('.page.video-player'))

playVideo = (src=null, time=0)->
  SM.stopMusic('music', 6000)
  $('body').addClass('is-playing')
  $('.page.visible').find('.player-footer-container').removeClass('mini')
  setVideoControls($('.page.visible'))
  $(currentVideo).unbind('play').bind('play', updateProgress)
  progressBarContainer.unbind('mousedown').bind('mousedown', controlProgress)
  progressBarContainer.unbind('mouseover').bind('mouseover', showCurrentInfo)
  currentVideo.currentTime = time
  currentVideo.play()

module.exports = {
  playVideo: playVideo,
  play: (chapter, time=0, chapterBg=null)->
    clearTimeout(pageTimeoutId)
    displayPage('.chapter', 'cross-dissolve', chapterBg)
    $('.player-footer-container').addClass('mini')
    setVideoControls($('.page.video-player'))
    currentVideo.currentTime = time
    pageTimeoutId = setTimeout(()->
      displayPage('.video-player')
      playVideo(null, time)
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

updateProgress = ()->
  requestAnimFrame(()->
    updateProgressBar()
    updateProgress() if !currentVideo.paused
  )

$(currentVideo).bind('ended', ()->
  console.log 'ended...'
)
$(currentVideo).bind('waiting', ()->
  console.log 'waiting...'
)
$(currentVideo).bind('playing', ()->
  console.log 'playing...'
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
controlProgress = (e)->
  currentVideo.pause()
  updateTime(e.clientX-progressBarContainer.offset().left-30)
  updateProgressBar()
  $(window).unbind('mousemove').unbind('mouseup').bind('mousemove', mouseMoveHandler).bind('mouseup', stopUpdateTime)
  progressBarContainer.unbind('mouseup').bind('mouseup', stopUpdateTime)

updateInfo = (e)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  left = e.clientX-progressBarContainer.offset().left
  infoTime = Math.ceil(duration * ((left-30) / progressBarContainer.find('.bar-container').width()))
  infoPopup.css('left', "#{left}px");
  infoPopup.find('.info').html(formatTime(infoTime))

stopShowCurrentInfo = (e)->
  infoPopup.css('display', 'none')
  progressBarContainer.unbind('mousemove').unbind('mouseout')

showCurrentInfo = (e)->
  infoPopup.css('display', 'block')
  progressBarContainer.unbind('mousemove').unbind('mouseout')
    .bind('mousemove', updateInfo).bind('mouseout', stopShowCurrentInfo)

leftKey = 37
rightKey = 39

$(window).bind('keyup', (e)->
  if !currentVideo.paused
    currentVideo.currentTime -= 10 if e.keyCode==37
    currentVideo.currentTime += 10 if e.keyCode==39
    currentVideo.play()
)

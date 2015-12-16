requestAnimFrame = require("animationframe")
displayPage = require "./displayPage.coffee"
require "./SoundWrapper"

pageTimeoutId = -1
currentVideo = null
progressBarContainer = null
progressBar = null
durationInfo = null
infoPopup = null
relatedItems = null
isInfoVisible = false

setVideoControls = (parent)->
  currentVideo = parent.find('.video video')[0]
  progressBarContainer = parent.find('.progress-bar-container')
  progressBar = parent.find('.bar-progress')
  durationInfo = parent.find('.duration-info')
  infoPopup = parent.find('.info-popup')
  relatedItems = parent.find('.related-container .related-item')

setVideoControls($('.page.video-player'))

playVideo = (src=null, time=0)->
  SM.stopMusic('music', 6000)
  $('body').addClass('is-playing')
  $('.page.visible').find('.player-footer-container').removeClass('mini')
  setVideoControls($('.page.visible'))
  $('footer').removeClass('hidden')
  $('html').removeClass('leanback')
  $(currentVideo).unbind('play').bind('play', updateProgress)
  progressBarContainer.unbind('mousedown').bind('mousedown', controlProgress)
  progressBarContainer.unbind('mouseover').bind('mouseover', showCurrentInfo)
  $(currentVideo).unbind('click').bind('click', togglePlay)
  infoPopup.unbind('mouseover').unbind('click').unbind('mousemove').unbind('mousedown').unbind('mouseup')
    .bind('mousemove', stopPropagation).bind('mousedown', stopPropagation).bind('mouseup', stopPropagation)
    .bind('mouseover', handleInfoMouseOver).bind('click', handleInfoPopupClick)
  currentVideo.currentTime = time
  currentVideo.play()

module.exports = {
  playVideo: playVideo,
  resumeVideo: ()->
    setVideoControls($('.page.visible'))
    playVideo(null, currentVideo.currentTime)
  play: (src=null, time=0, chapterBg=null)->
    clearTimeout(pageTimeoutId)
    displayPage('.chapter', 'cross-dissolve', chapterBg)
    $('footer').removeClass('hidden')
    $('.player-footer-container').addClass('mini')
    setVideoControls($('.page.video-player'))
    currentVideo.currentTime = time
    pageTimeoutId = setTimeout(()->
      displayPage('.video-player')
      playVideo(src, time)
    , 4000)
  stop: ()->
    currentVideo.pause() if currentVideo
    setVideoControls($('.page.visible'))
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
  return if !currentVideo
  offset = parseInt(progressBarContainer.css('padding-left'))
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  currentTime = if !currentVideo? || isNaN(currentVideo.currentTime) then 0 else currentVideo.currentTime
  progress = currentTime/duration * 100

  progressBar.css('transition-duration', "16ms")
  progressBar.css('width', "#{progress}%")
  durationInfo.html("#{formatTime(currentTime)} | #{formatTime(duration)}")
  if !isInfoVisible
    if item = isTimeOverRelatedItem(currentVideo.currentTime, 10)
      infoPopup.css('left', "#{item.position().left+offset}px");
      infoPopup.removeClass('compact')
      infoPopup.removeClass('hidden')
      infoPopup.find('.info').html(item.find('.info').html())
    else
      infoPopup.addClass('compact')
      infoPopup.addClass('hidden')

$(currentVideo).bind('ended', ()->
  console.log 'ended...'
)

updateProgress = ()->
  requestAnimFrame(()->
    updateProgressBar()
    updateProgress() if currentVideo && !currentVideo.paused
  )

$(currentVideo).bind('ended', ()->
  console.log 'ended...'
  module.exports.stop()
  module.exports.play()
)
$(currentVideo).bind('waiting', ()->
#  console.log 'waiting...'
  $('.page.visible .buffering').removeClass('hidden')
)
$(currentVideo).bind('playing', ()->
#  console.log 'playing...'
  $('.page.visible .buffering').addClass('hidden')
)

updateTime = (x)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  position = (x) / progressBarContainer.width()
  currentVideo.currentTime = duration * position

mouseMoveHandler = (e)->
  offset = parseInt(progressBarContainer.css('padding-left'))
  updateTime(e.clientX-progressBarContainer.offset().left-offset)
  updateProgressBar()
  e.stopImmediatePropagation()
  return false

stopUpdateTime = ()->
  progressBarContainer.unbind('mouseup')
  $(window).unbind('mousemove').unbind('mouseup')
  currentVideo.play() if $('body').hasClass('is-playing')
controlProgress = (e)->
  offset = parseInt(progressBarContainer.css('padding-left'))
  currentVideo.pause()
  updateTime(e.clientX-progressBarContainer.offset().left-offset)
  updateProgressBar()
  $(window).unbind('mousemove').unbind('mouseup')
    .bind('mousemove', mouseMoveHandler).bind('mouseup', stopUpdateTime)
  progressBarContainer.unbind('mouseup').bind('mouseup', stopUpdateTime)

isTimeOverRelatedItem = (currentTime, displayTime=null)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  position = Math.ceil(currentTime / duration * 100)
  item = null
  relatedItems.each(()->
    p = parseInt($(this).attr('style').replace('left:',''), 10)
    if displayTime
      d = p / 100 * duration
      item = $(this) if (d>currentTime-displayTime/2 && d<currentTime+displayTime/2)
    else
      item = $(this) if p==position || p-1==position || p+1==position
  )
  return item

updateInfo = (e)->
  offset = parseInt(progressBarContainer.css('padding-left'))
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  left = e.clientX-progressBarContainer.offset().left
  infoTime = Math.ceil(duration * ((left-offset) / progressBarContainer.find('.bar-container').width()))
  if item = isTimeOverRelatedItem(infoTime)
    infoPopup.removeClass('compact')
#    infoPopup.find('.info').html(formatTime(infoTime))
    infoPopup.find('.info').html(item.find('.info').html() + '<br>' +formatTime(infoTime))
  else
    infoPopup.addClass('compact')
    infoPopup.find('.info').html(formatTime(infoTime))

  if (left-offset>=0 && left-offset<=progressBarContainer.find('.bar-container').width())
    if item
      infoPopup.css('left', "#{item.position().left+offset}px");
    else
      infoPopup.css('left', "#{left}px");


stopShowCurrentInfo = (e)->
  isInfoVisible = false
#  infoPopup.addClass('hidden')
  progressBarContainer.unbind('mousemove').unbind('mouseout')

showCurrentInfo = (e)->
  isInfoVisible = true
  infoPopup.removeClass('hidden')
  progressBarContainer.unbind('mousemove').unbind('mouseout')
    .bind('mousemove', updateInfo).bind('mouseout', stopShowCurrentInfo)

handleInfoMouseOver = (e)->
  infoPopup.removeClass('hidden')


stopPropagation = (e)->
  infoPopup.removeClass('hidden')
  e.stopImmediatePropagation()
  return false

togglePlay = ()->
  if this.paused
    this.play()
    $(currentVideo).parent().find('.pause').addClass('hidden')
    $(currentVideo).parent().find('.play').removeClass('hidden')
    $('body').addClass('is-playing')
  else
    this.pause()
    $(currentVideo).parent().find('.play').addClass('hidden')
    $(currentVideo).parent().find('.pause').removeClass('hidden')
    $('body').removeClass('is-playing')

leftKey = 37
rightKey = 39

$(window).bind('keyup', (e)->
  if currentVideo
    currentVideo.currentTime -= 10 if e.keyCode==37
    currentVideo.currentTime += 10 if e.keyCode==39
    currentVideo.play() if !currentVideo.paused
)
handleInfoPopupClick = (e)->
  stopPropagation(e)
  currentVideo.pause() if currentVideo
  infoPopup.addClass('hidden')
  $('.video-player-compact-documentary').addClass('slide-down')
  displayPage('.video-player-compact-documentary', '')
  $('.video-player-compact-documentary .player-footer-container').removeClass('mini')
  createjs.Sound.play("page-slide-up")
  playVideo()

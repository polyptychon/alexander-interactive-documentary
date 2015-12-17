requestAnimFrame = require("animationframe")
displayPage = require "./displayPage.coffee"
require "./SoundWrapper"

pageTimeoutId = -1
videoTimeoutId = -1
currentVideo = null
progressBarContainer = null
progressBar = null
durationInfo = null
infoPopup = null
relatedItems = null
isInfoVisible = false
chapterManager = require "./chapters.coffee"

setVideoControls = (parent)->
  currentVideo = parent.find('.video video')[0]
  progressBarContainer = parent.find('.progress-bar-container')
  progressBar = parent.find('.bar-progress')
  durationInfo = parent.find('.duration-info')
  infoPopup = parent.find('.info-popup')
  relatedItems = parent.find('.related-container .related-item')

  $(currentVideo)
    .unbind('play').bind('play', updateProgress)
    .unbind('click').bind('click', togglePlay)
    .unbind('ended').bind('ended', handleVideoEnded)
    .unbind('waiting').bind('waiting', handleVideoWaiting)
    .unbind('playing').bind('playing', handleVideoPlaying)
  progressBarContainer
    .unbind('mousedown').bind('mousedown', controlProgress)
    .unbind('mouseover').bind('mouseover', showCurrentInfo)
  infoPopup
    .unbind('mouseover').bind('mouseover', handleInfoMouseOver)
    .unbind('click').bind('click', handleInfoPopupClick)
    .unbind('mousemove').bind('mousemove', stopPropagation)
    .unbind('mousedown').bind('mousedown', stopPropagation)
    .unbind('mouseup').bind('mouseup', stopPropagation)
  $(window).unbind('keyup').bind('keyup', handleKeyEvents)

setVideoControls($('.page.video-player'))

setVideoSource = (src, parent=null)->
  parent = $('.page.visible .video') if parent==null
  if src && parent.length>0
    videoHTML =  "<video preload=\"true\">"
    videoHTML += "<source src=\"#{src.webm}\" type=\"video/webm\">" if src.webm
    videoHTML += "<source src=\"#{src.mp4}\" type=\"video/mp4\">" if src.mp4
    videoHTML += "</video>"
    videoHTML += "<div class=\"buffering hidden\"></div>"
    videoHTML += "<div class=\"play hidden\"></div>"
    videoHTML += "<div class=\"pause hidden\"></div>"
    parent.html(videoHTML)

playVideo = (src=null, time=0)->
  setVideoSource(src)
  SM.stopMusic('music', 6000)
  $('body').addClass('is-playing')
  $('.page.visible').find('.player-footer-container').removeClass('mini')
  setVideoControls($('.page.visible'))
  $('footer').removeClass('hidden')
  $('html').removeClass('leanback')
  if currentVideo
    currentVideo.currentTime = time
    currentVideo.play()

module.exports = {
  playVideo: playVideo,
  resumeVideo: ()->
    setVideoControls($('.page.visible'))
    playVideo(null, currentVideo.currentTime)
  play: (src=null, time=0, chapterBg=null)->
    clearTimeout(pageTimeoutId)
    clearTimeout(videoTimeoutId)
    $('.chapter h1').html(chapterManager.getCurrentChapterTitle())
    $('.chapter h2 .number').html(chapterManager.currentChapterPlaying+1)
    displayPage('.chapter', 'cross-dissolve', chapterBg)
    $('footer').removeClass('hidden')
    $('.player-footer-container').addClass('mini')
    videoTimeoutId = setTimeout(()->
      setVideoSource(src, $('.page.video-player .video'))
      setVideoControls($('.page.video-player'))
      currentVideo.currentTime = time
    , 500)
    pageTimeoutId = setTimeout(()->
      displayPage('.video-player')
      playVideo(null, time)
    , 4000)
  stop: ()->
    stopShowCurrentInfo()
    $(currentVideo).unbind('play').unbind('click')
      .unbind('ended').unbind('waiting').unbind('playing')
    currentVideo.pause() if currentVideo
    clearTimeout(pageTimeoutId)
    clearTimeout(videoTimeoutId)
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
    if currentVideo && !currentVideo.paused
      updateProgressBar()
      updateProgress()
  )

handleVideoEnded = ()->
#  console.log 'ended...'
  chapterManager.currentChapterPlaying++
  $('footer').removeClass('hidden')
  module.exports.stop()
  if chapterManager.currentChapterPlaying<chapterManager.chapters.length
    module.exports.play(chapterManager.getCurrentChapterSource())
  else
    chapterManager.currentChapterPlaying = 0
    displayPage('.landing')

handleVideoWaiting = ()->
#  console.log 'waiting...'
  $('.page.visible .buffering').removeClass('hidden')

handleVideoPlaying = ()->
#  console.log 'playing...'
  $('.page.visible .buffering').addClass('hidden')


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
  if currentVideo.paused
    currentVideo.play()
    $(currentVideo).parent().find('.pause').addClass('hidden')
    $(currentVideo).parent().find('.play').removeClass('hidden')
    $('body').addClass('is-playing')
  else
    currentVideo.pause()
    $(currentVideo).parent().find('.play').addClass('hidden')
    $(currentVideo).parent().find('.pause').removeClass('hidden')
    $('body').removeClass('is-playing')

LEFT_KEY = 37
RIGHT_KEY = 39
SPACE_KEY = 32

handleKeyEvents = (e)->
  if currentVideo
    currentVideo.currentTime -= 10 if e.keyCode==LEFT_KEY
    currentVideo.currentTime += 10 if e.keyCode==RIGHT_KEY
    if e.keyCode==SPACE_KEY
      togglePlay()
    else
      currentVideo.play() if !currentVideo.paused

handleInfoPopupClick = (e)->
  stopPropagation(e)
  currentVideo.pause() if currentVideo
  infoPopup.addClass('hidden')
  $('.video-player-compact-documentary').addClass('slide-down')
  displayPage('.video-player-compact-documentary', '')
  $('.video-player-compact-documentary .player-footer-container').removeClass('mini')
  createjs.Sound.play("page-slide-up")
  playVideo()

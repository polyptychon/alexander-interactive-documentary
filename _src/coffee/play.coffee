require "./SoundWrapper"
require "jquery-touch-events"
requestAnimFrame = require "animationframe"
displayPage = require "./displayPage.coffee"
chapterManager = require "./Chapters.coffee"
srtParser = require "subtitles-parser"
formatTime = require "./formatTime.coffee"
ls = require 'local-storage'

LEFT_KEY = 37
RIGHT_KEY = 39
SPACE_KEY = 32
START_VIDEO_DURATION = 4000

pageTimeoutId = -1
videoTimeoutId = -1
isPlayingIntervalId = -1
infoTimeout = -1
previousTime = 0

currentVideo = null
playerContainer = null
progressBarContainer = null
progressBar = null
chapterInfo = null
durationInfo = null
infoPopup = null
relatedVideosContainer = null
relatedItemsContainer = null
relatedItems = null
chaptersContainer = null

subtitlesButton = null
chapterButton = null
relatedVideosButton = null
muteButton = null

subtitles = null
parsedSubtitle = null
isInfoVisible = false
currentSub = ''

clearTimeOuts = ()->
  clearTimeout(pageTimeoutId)
  clearTimeout(videoTimeoutId)
  clearTimeout(infoTimeout)
  clearInterval(isPlayingIntervalId)

removeEvents = ()->
  if currentVideo
    $(currentVideo).parent()
      .unbind('click')
    $(currentVideo)
      .unbind('play')
      .unbind('ended')
      .unbind('waiting')
      .unbind('playing')
      .unbind('loadedmetadata')
      .unbind('canplay')
      .unbind('canplaythrough')
      .unbind('stalled')
      .unbind('error')
  if progressBarContainer
    progressBarContainer
      .unbind('mousedown')
      .unbind('mouseover')
      .unbind('mouseup')
      .unbind('tapstart')
      .unbind('tapmove')
      .unbind('tapend')
  if infoPopup
    infoPopup
      .unbind('mouseover')
      .unbind('mouseout')
      .unbind('click')
      .unbind('mousemove')
      .unbind('mousedown')
      .unbind('mouseup')
  $(window)
    .unbind('keyup')
    .unbind('mousemove')
    .unbind('mouseup')
  if subtitlesButton
    subtitlesButton
      .unbind('click')
      .unbind('tap')
  if muteButton
    muteButton
      .unbind('click')
      .unbind('tap')
  if chapterButton
    chapterButton
      .unbind('click')
      .unbind('tap')
  if relatedVideosButton
    relatedVideosButton
      .bind('mouseover')
      .unbind('click')
      .unbind('tap')

addEvents = ()->
  $(currentVideo).parent()
    .bind('click', togglePlay)
  $(currentVideo)
    .bind('play', updateProgress)
    .bind('ended', handleVideoEnded)
    .bind('waiting', handleVideoWaiting)
    .bind('playing', handleVideoPlaying)
    .bind('loadedmetadata', handleVideoMetadata)
    .bind('canplaythrough', handleVideCanPlayThrough)
    .bind('stalled', handleVideoStalled)
    .bind('error', handleVideoError)
  progressBarContainer
    .bind('mousedown', controlProgress)
    .bind('mouseover', showCurrentInfo)
    .bind('tapstart', controlProgress)
  infoPopup
    .bind('mouseover', handleInfoMouseOver)
    .bind('mouseout', handleInfoMouseOut)
    .bind('click', handleInfoPopupClick)
    .bind('mousemove', stopInfoPopupPropagation)
    .bind('mousedown', stopInfoPopupPropagation)
    .bind('mouseup', stopInfoPopupPropagation)
  $(window)
    .bind('keyup', handleKeyEvents)

  if $('html').hasClass('hasTouch')
    subtitlesButton
      .bind('tap', handleSubtitles)
    muteButton
      .bind('tap', handleMute)
    chapterButton
      .bind('tap', handleChaptersButtonClick)
    relatedVideosButton
      .bind('tap', handleRelatedVideosButtonClick)
  else
    subtitlesButton
      .bind('click', handleSubtitles)
    muteButton
      .bind('click', handleMute)
    chapterButton
      .bind('click', handleChaptersButtonClick)
    relatedVideosButton
      .bind('mouseover', handleRelatedVideosButtonOver)
      .bind('click', handleRelatedVideosButtonClick)

setVideoControls = (parent)->
  currentVideo = parent.find('.video video')[0]
  progressBarContainer = parent.find('.progress-bar-container')
  playerContainer = parent.find('.player-footer-container')
  progressBar = parent.find('.bar-progress')
  durationInfo = parent.find('.duration-info')
  chapterInfo = parent.find('.chapter-info')
  infoPopup = parent.find('.info-popup')
  relatedVideosContainer = parent.find('.related-videos-container .related-videos')
  relatedItemsContainer = parent.find('.related-container .related-items')
  relatedItems = parent.find('.related-container .related-item')
  subtitlesButton = parent.find('.subs-btn')
  muteButton = parent.find('.mute-btn')
  subtitles = parent.find('.subtitles')
  chapterButton = parent.find('.chapters-btn')
  relatedVideosButton = parent.find('.related-items-btn')
  chaptersContainer = parent.find('.chapters-intro-container')
  removeEvents()
  addEvents()

setVideoSource = (src, parent=null, force=false)->
  parent = $('.page.visible .video') if parent==null
  if src && parent.length>0
    parent.each(()->
      if (($(this).find('source[type="video/webm"]').attr('src')!=src.webm &&
           $(this).find('source[type="video/mp4"]').attr('src')!=src.mp4) || force)
        videoHTML =  "<video preload=\"true\">"
        if $('html').hasClass('hasTouch')
          videoHTML += "<source src=\"#{src.mp4}\" type=\"video/mp4\">" if src.mp4
          videoHTML += "<source src=\"#{src.webm}\" type=\"video/webm\">" if src.webm
        else
          videoHTML += "<source src=\"#{src.webm}\" type=\"video/webm\">" if src.webm
          videoHTML += "<source src=\"#{src.mp4}\" type=\"video/mp4\">" if src.mp4
        videoHTML += "</video>"
        videoHTML += "<div class=\"buffering hidden\"></div>"
        videoHTML += "<div class=\"play hidden\"></div>"
        videoHTML += "<div class=\"pause hidden\"></div>"
        videoHTML += "<div class=\"subtitles\"></div>"
        $(this).html(videoHTML)
        currentVideo = parent.find('.video video')[0]
    )
    return src
  else
    webm = $(currentVideo).find('source[type="video/webm"]')
    mp4 = $(currentVideo).find('source[type="video/mp4"]')
    src = {}
    src.webm = webm.attr('src') if webm.length>0
    src.mp4 = mp4.attr('src') if mp4.length>0
    return src
setRelatedItems = (relatedData)->
  return null if (
    !relatedData? ||
    relatedData.length==0 ||
    relatedItemsContainer==null ||
    relatedItemsContainer.length==0
  )
  html = ""
  htmlList = ""
  for relatedItem, index in relatedData
    if currentVideo? && !isNaN(currentVideo.duration)
      time = formatTime.timeToMiliSeconds(relatedItem.startTime)
      p = Math.ceil(time/Math.ceil(currentVideo.duration*1000) * 100)
      thumbnail =
        if (relatedItem.thumbnail? && relatedItem.thumbnail!="")
        then relatedItem.thumbnail
        else "assets/images/thumbnail.jpg"
      html += """
      <div style="left:#{p}%;" class="related-item" data-index="#{index}">
        <div class="related-item-popup">
          <div style="background-image: url(#{thumbnail})" class="img"></div>
          <div class="info">#{relatedItem.title}</div>
        </div>
      </div>
      """
    htmlList += """
      <li>
        <a data-index="#{index}">
          <div class="img"><img src="#{thumbnail}"></div>
          <div class="info">#{relatedItem.title}</div>
        </a>
      </li>
    """
  if currentVideo? && !isNaN(currentVideo.duration)
    relatedItemsContainer.html(html)
    relatedItems = relatedItemsContainer.find('.related-item')
  relatedVideosContainer.html(htmlList)
  relatedVideosContainer.find('a')
    .unbind('click').bind('click',handleRelatedVideoClick)
    .unbind('mouseover').bind('mouseover', handleRelatedVideoOver)

currentVideoPlay = ()->
  clearInterval(isPlayingIntervalId)
  if currentVideo
    $('.buffering').addClass('hidden')
    $(currentVideo).parent().find('.play').addClass('hidden')
    $(currentVideo).parent().find('.play').removeClass('visible')
    currentVideo.play()
    previousTime = currentVideo.currentTime if currentVideo.currentTime
    video = chapterManager.getVideoFromSource($(currentVideo).find('source').attr('src'))
    video.isPlayedOnce = true
    detectIsPlaying()
    updateProgress()

setCurrentTime = (time)->
  try
    currentVideo.currentTime = time if currentVideo
  catch e

currentVideoPause = ()->
  clearInterval(isPlayingIntervalId)
  currentVideo.pause() if currentVideo

playVideo = (src=null, time=0)->
  requestAnimFrame(()->
    requestAnimFrame(()->
      src = setVideoSource(src)
      SM.stopMusic('music', 1000)
      $('body').addClass('is-playing')
      $('.page.visible').find('.player-footer-container').removeClass('mini')
      setVideoControls($('.page.visible'))
      relatedItemsContainer.html('')
      relatedVideosContainer.html('')
      $('footer').removeClass('hidden')
      $('html').removeClass('leanback')
      infoPopup.addClass('hidden')
      if currentVideo
        setCurrentTime(time)
        currentVideo.muted = $('body').hasClass('mute')
        video = chapterManager.getVideoFromSource(src.webm)
        if $('html').hasClass('videoautoplay') || video.isPlayedOnce || !$('html').hasClass('hasTouch')
          $(currentVideo).parent().find('.play').removeClass('visible')
          currentVideoPlay()
        else
          $(currentVideo).parent().find('.play').removeClass('hidden')
          $(currentVideo).parent().find('.play').addClass('visible')
        parsedSubtitle = null
        setRelatedItems(chapterManager.getCurrentChapterRelatedItems())
        loadSubtitles()
        chapterInfo.html("#{chapterManager.getCurrentChapterPlaying()+1}. #{chapterManager.getCurrentChapterTitle()}")
    )
  )
resumeVideo = ()->
  requestAnimFrame(()->
    requestAnimFrame(()->
      setVideoControls($('.page.visible'))
      playVideo(null, currentVideo.currentTime)
    )
  )
play = (src=null, time=0, chapterBg=null)->
  clearTimeOuts()
  $('.chapter h1').html(chapterManager.getCurrentChapterTitle())
  $('.chapter h2 .number').html(chapterManager.getCurrentChapterPlaying()+1)
  displayPage('.chapter', 'cross-dissolve', chapterBg)
  $('footer').removeClass('hidden')
  playerContainer.addClass('mini') if playerContainer
  $('.page.video-player').css('display', 'block')

  videoTimeoutId = setTimeout(()->
    setVideoSource(src, $('.page.video-player .video'))
    setVideoControls($('.page.video-player'))
    chaptersContainer.find('li.active').removeClass('active')
    chaptersContainer.find('li').eq(chapterManager.getCurrentChapterPlaying()).addClass('active')
    setCurrentTime(time)
    ls.set(chapterManager.LOCAL_STORAGE_CHAPTER, chapterManager.getCurrentChapterPlaying())
    ls.set(chapterManager.LOCAL_STORAGE_TIME, time)
    currentVideo.play()
    currentVideo.muted = true
    loadSubtitles()
    $(currentVideo)
      .bind('canplaythrough', currentVideo.pause)
      .bind('loadedmetadata', handleVideoMetadata)
  , 1000)

  pageTimeoutId = setTimeout(()->
    displayPage('.video-player')
    playVideo(null, time)
  , START_VIDEO_DURATION)

stop = ()->
  stopShowCurrentInfo()
  removeEvents()
  clearTimeOuts()
  $('.buffering').addClass('hidden')
  currentVideoPause()
  $('body').removeClass('is-playing')
  SM.playMusic('music', -1, 1000)

getCurrentSubtitle = (currentTime)->
  subs = parsedSubtitle
  currentTime = Math.ceil(currentTime*1000)
  return sub.text.replace('\n', '<br>') for sub in subs when sub.startTime<=currentTime && sub.endTime>=currentTime
  return ''

updateProgressBar = ()->
  offset = parseInt(progressBarContainer.css('padding-left'))
  duration = if !currentVideo || isNaN(currentVideo.duration) then 0 else currentVideo.duration
  currentTime = if !currentVideo || isNaN(currentVideo.currentTime) then 0 else currentVideo.currentTime
  ls.set(chapterManager.LOCAL_STORAGE_TIME, currentTime) if !playerContainer.hasClass('compact')
  progress = currentTime/duration * 100
  progress = if isNaN(progress) then 0 else progress

  progressBar.css('transition-duration', "16ms")
  progressBar.css('width', "#{progress}%")

  durationInfo.html("#{formatTime.miliSecondsToTime(currentTime)} | #{formatTime.miliSecondsToTime(duration)}")

  if (parsedSubtitle &&
      $('body').hasClass('show-subtitles'))
    
    sub = getCurrentSubtitle(currentTime)
    subtitles.html(sub) if sub != currentSub
    currentSub = sub

  if !isInfoVisible && !$('body').hasClass('show-chapters')
    if item = isTimeOverRelatedItem(currentTime, 10)
      p = parseInt(item.attr('style').replace('left:',''), 10)/100*progressBarContainer.find('.bar-container').width()
      infoPopup.css('left', "#{p+offset}px");
      infoPopup.removeClass('compact')
      infoPopup.removeClass('hidden')
      infoPopup.data('index', item.data('index'))
      infoPopup.find('.info').html(item.find('.info').html())
    else
      infoPopup.addClass('compact')
      infoPopup.addClass('hidden')

detectIsPlaying = ()->
  isPlayingIntervalId = setInterval(()->
    if currentVideo && !currentVideo.paused && currentVideo.currentTime && currentVideo.currentTime!=previousTime
      previousTime = currentVideo.currentTime
      $(currentVideo).parent().find('.play').removeClass('visible')
      $(currentVideo).parent().find('.buffering').addClass('hidden')
  ,1000)
updateProgress = ()->
  requestAnimFrame(()->
    updateProgressBar()
    updateProgress() if currentVideo && !currentVideo.paused

  )
handleVideoMetadata = ()->
#  console.log 'metadata...'
  setRelatedItems(chapterManager.getCurrentChapterRelatedItems())
  updateProgressBar()

handleVideoEnded = ()->
#  console.log 'ended...	Sent when playback completes.'
  $('footer').removeClass('hidden')
  stop()
  if $('.page.video-player-compact-documentary').hasClass('visible')
    displayPage('.video-player', '')
    createjs.Sound.play("page-slide-back")
    resumeVideo()
  else if $('.page.video-player-compact').hasClass('visible')

  else
    if chapterManager.getCurrentChapterPlaying()+1<chapterManager.getTotalChapter()
      chapterManager.setCurrentChapterPlaying(chapterManager.getCurrentChapterPlaying()+1)
      play(chapterManager.getCurrentChapterSource())
    else
      ls.clear()
      chapterManager.setCurrentChapterPlaying(0)
      displayPage('.landing')

handleVideoWaiting = ()->
#  console.log 'waiting...'
  infoPopup.addClass('hidden')
  $('.buffering').removeClass('hidden')

handleVideoPlaying = ()->
#  console.log 'playing...'
#  clearInterval(isPlayingIntervalId)
  setRelatedItems(chapterManager.getCurrentChapterRelatedItems())
  infoPopup.addClass('hidden')
  $('.buffering').addClass('hidden')

handleVideCanPlayThrough = ()->
#  console.log 'canplaythrough...'
  $('.buffering').addClass('hidden')

handleVideoStalled = ()->
#  console.log 'stalled...The stalled event is fired when the user agent is trying to fetch media data, but data is unexpectedly not forthcoming.'
  $('.buffering').removeClass('hidden')

handleVideoError = ()->
  console.log 'error...'
  $('.buffering').addClass('hidden')

updateTime = (x)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  position = (x) / progressBarContainer.width()
  setCurrentTime(duration * position)

mouseMoveHandler = (e, touch)->
  offset = parseInt(progressBarContainer.css('padding-left'))
  x = if touch then touch.offset.x-offset else e.clientX-progressBarContainer.offset().left-offset
  updateTime(x)
  updateProgressBar()
  e.stopImmediatePropagation()
  return false

stopUpdateTime = ()->
  progressBarContainer
    .unbind('mouseup')
    .unbind('tapmove')
    .unbind('tapend')
  $(window)
    .unbind('mousemove')
    .unbind('mouseup')
  currentVideoPlay() if $('body').hasClass('is-playing')

controlProgress = (e, touch)->
  offset = parseInt(progressBarContainer.css('padding-left'))
  x = if touch then touch.offset.x-offset else e.clientX-progressBarContainer.offset().left-offset
  currentVideoPause()
  updateTime(x)
  updateProgressBar()
  $(window)
    .unbind('mousemove').bind('mousemove', mouseMoveHandler)
    .unbind('mouseup').bind('mouseup', stopUpdateTime)
  progressBarContainer
    .unbind('tapmove').bind('tapmove', mouseMoveHandler)
    .unbind('tapend').bind('tapend', stopUpdateTime)
    .unbind('mouseup').bind('mouseup', stopUpdateTime)

isTimeOverRelatedItem = (currentTime, displayTime=null)->
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  position = Math.ceil(currentTime / duration * 100)
  item = null
  return null if isNaN(duration) || isNaN(position)
  relatedItems.each(()->
    p = parseInt($(this).attr('style').replace('left:',''), 10)
    if displayTime
      d = p / 100 * duration
      item = $(this) if (d>currentTime-displayTime/2 && d<currentTime+displayTime/2)
    else
      item = $(this) if p==position || p+1==position
  )
  return item

updateInfo = (e)->
  offset = parseInt(progressBarContainer.css('padding-left'))
  duration = if isNaN(currentVideo.duration) then 0 else currentVideo.duration
  left = e.clientX-progressBarContainer.offset().left
  infoTime = Math.ceil(duration * ((left-offset) / progressBarContainer.find('.bar-container').width()))
  if item = isTimeOverRelatedItem(infoTime)
    infoPopup.removeClass('compact')
    infoPopup.data("index", item.data('index'))
    infoPopup.find('.info').html(item.find('.info').html() + '<br>' +formatTime.miliSecondsToTime(infoTime))
  else
    infoPopup.addClass('compact')
    infoPopup.find('.info').html(formatTime.miliSecondsToTime(infoTime))

  if (left-offset>=0 && left-offset<=progressBarContainer.find('.bar-container').width())
    if item
      p = parseInt(item.attr('style').replace('left:',''), 10)/100*progressBarContainer.find('.bar-container').width()
      infoPopup.css('left', "#{p+offset}px");
    else
      infoPopup.css('left', "#{left}px");

handleInfoMouseOut = (e)->
  clearTimeout(infoTimeout)
  if (!$(this).hasClass('compact'))
    infoTimeout = setTimeout(()->
      stopShowCurrentInfo()
    , 400)
    e.stopImmediatePropagation()
    return false

stopShowCurrentInfo = (e)->
  isInfoVisible = false
  infoPopup.addClass('hidden') if infoPopup
  progressBarContainer.unbind('mousemove').unbind('mouseout')  if progressBarContainer

showCurrentInfo = (e)->
  clearTimeout(infoTimeout)
  isInfoVisible = true
  infoPopup.removeClass('hidden')
  progressBarContainer.unbind('mousemove').unbind('mouseout')
    .bind('mousemove', updateInfo).bind('mouseout', stopShowCurrentInfo)

handleInfoMouseOver = (e)->
  infoPopup.removeClass('hidden')


stopInfoPopupPropagation = (e)->
  infoPopup.removeClass('hidden')
  e.stopImmediatePropagation()
  return false

togglePlay = ()->
  if currentVideo.paused
    currentVideoPlay()
    $(currentVideo).parent().find('.pause').addClass('hidden')
    $(currentVideo).parent().find('.play').removeClass('hidden')
    $('body').addClass('is-playing')
  else
    currentVideoPause()
    $('.buffering').addClass('hidden')
    $(currentVideo).parent().find('.play').addClass('hidden')
    $(currentVideo).parent().find('.pause').removeClass('hidden')
    $('body').removeClass('is-playing')

handleKeyEvents = (e)->
  if currentVideo
    try
      currentVideo.currentTime -= 10 if e.keyCode==LEFT_KEY
      currentVideo.currentTime += 10 if e.keyCode==RIGHT_KEY
    catch e
    updateProgressBar()
    if e.keyCode==SPACE_KEY
      togglePlay()
    else if !currentVideo.paused
      currentVideoPlay()

playRelatedVideo = (index)->
  currentVideoPause()
  infoPopup.addClass('hidden')
  $('.video-player-compact-documentary').addClass('slide-down')
  displayPage('.video-player-compact-documentary')
  $('.video-player-compact-documentary .player-footer-container').removeClass('mini')
  createjs.Sound.play("page-slide-up")
  playVideo(chapterManager.getCurrentChapterRelatedItemByIndex(index).source)

handleInfoPopupClick = (e)->
  stopInfoPopupPropagation(e)
  clearTimeout(videoTimeoutId)
  playRelatedVideo($(this).data('index'))

loadSubtitles = ()->
  subtitles.html('') if subtitles?
  video = chapterManager.getVideoFromSource($(currentVideo).find('source').attr('src'))
  parsedSubtitle = video.parsedSubtitle
  if video? && !video.parsedSubtitle
    $.get video.subtitle, (data)->
      parsedSubtitle = video.parsedSubtitle = srtParser.fromSrt(data, true)


handleSubtitles = ()->
  $('body').toggleClass('show-subtitles')
  ls.set(chapterManager.LOCAL_STORAGE_SHOW_SUBTITLES, $('body').hasClass('show-subtitles'))
  loadSubtitles()

handleMute = ()->
  $('body').toggleClass('mute')
  currentVideo.muted = !currentVideo.muted

handleChaptersButtonClick = ()->
  $('body').toggleClass('show-chapters')
  infoPopup.addClass('hidden')

handleRelatedVideosButtonOver = ()->
#  createjs.Sound.play("over")

handleRelatedVideosButtonClick = ()->
  infoPopup.addClass('hidden')
  $('body').removeClass('show-chapters')
  playerContainer.toggleClass('open-related-items')

handleRelatedVideoClick = ()->
#  createjs.Sound.play("click")
  playRelatedVideo($(this).data('index'))

handleRelatedVideoOver = ()->
  createjs.Sound.play("over")

module.exports = {
  setVideoSource: setVideoSource,
  playVideo: playVideo,
  resumeVideo: resumeVideo,
  play: play,
  stop: stop
}

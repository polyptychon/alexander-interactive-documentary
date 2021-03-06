require "./SoundWrapper"
require "jquery-touch-events"
require "./modernizr-custom"
requestAnimFrame = require "animationframe"
displayPage = require "./displayPage.coffee"
chapterManager = require "./Chapters.coffee"
srtParser = require "subtitles-parser"
formatTime = require "./formatTime.coffee"
browser = require "detect-browser"
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
bufferBar = null
chapterInfo = null
durationInfo = null
infoPopup = null
relatedVideosContainer = null
relatedVideos = null
relatedVideosPrevious = null
relatedVideosNext = null
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
      .unbind('progress')
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
      .unbind('tap')
      .unbind('mousemove')
      .unbind('mousedown')
      .unbind('mouseup')
  $(window)
    .unbind('keyup')
    .unbind('mousemove')
    .unbind('mouseup')
    .unbind('resize')
  if subtitlesButton
    subtitlesButton
      .unbind('click')
      .unbind('singletap')
  if muteButton
    muteButton
      .unbind('click')
      .unbind('singletap')
  if chapterButton
    chapterButton
      .unbind('click')
      .unbind('singletap')
  if relatedVideosButton
    relatedVideosButton
      .bind('mouseover')
      .unbind('click')
      .unbind('tap')
    relatedVideosButton.parent()
      .unbind('swipeup')
      .unbind('swipedown')
  if relatedVideosPrevious
    relatedVideosPrevious
      .unbind('click')
  if relatedVideosNext
    relatedVideosNext
      .unbind('click')

addEvents = ()->
  $(currentVideo)
    .bind('play', updateProgress)
    .bind('ended', handleVideoEnded)
    .bind('waiting', handleVideoWaiting)
    .bind('playing', handleVideoPlaying)
#    .bind('progress', handleVideoProgress)
    .bind('loadedmetadata', handleVideoMetadata)
    .bind('canplaythrough', handleVideCanPlayThrough)
    .bind('stalled', handleVideoStalled)
    .bind('error', handleVideoError)
  progressBarContainer
    .bind('mousedown', controlProgress)
    .bind('mouseover', showCurrentInfo)
  infoPopup
    .bind('mouseover', handleInfoMouseOver)
    .bind('mouseout', handleInfoMouseOut)
    .bind('mousemove', stopInfoPopupPropagation)
    .bind('mousedown', stopInfoPopupPropagation)
    .bind('mouseup', stopInfoPopupPropagation)
  $(window)
    .bind('keyup', handleKeyEvents)
    .bind('resize', handleWindowResize)
  relatedVideosPrevious
    .bind('click', handleRelatedVideosPreviousClick)
  relatedVideosNext
    .bind('click', handleRelatedVideosNextClick)

  if Modernizr.touchevents && browser.name != "ie"
    progressBarContainer
      .bind('tapstart', controlProgress)
    $(currentVideo).parent()
      .bind('tap', togglePlay)
    subtitlesButton
      .bind('tap', handleSubtitles)
    infoPopup
      .bind('tap', handleInfoPopupClick)
    muteButton
      .bind('tap', handleMute)
    chapterButton
      .bind('tap', handleChaptersButtonClick)
    relatedVideosButton
      .bind('tap', handleRelatedVideosButtonClick)
    relatedVideosButton.parent()
      .bind('swipeup', handleRelatedVideosButtonSwipeUp)
      .bind('swipedown', handleRelatedVideosButtonSwipeDown)
  else
    infoPopup
      .bind('click', handleInfoPopupClick)
    $(currentVideo).parent()
      .bind('click', togglePlay)
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
  bufferBar = parent.find('.bar-buffered')
  durationInfo = parent.find('.duration-info')
  chapterInfo = parent.find('.chapter-info')
  infoPopup = parent.find('.info-popup')
  relatedVideosContainer = parent.find('.related-videos-container')
  relatedVideos = parent.find('.related-videos-container .related-videos')
  relatedVideosPrevious = relatedVideosContainer.find('.previous')
  relatedVideosNext = relatedVideosContainer.find('.next')
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

getVideoSource = ()->
  if currentVideo then $(currentVideo).attr('src') else ""

setVideoSource = (src, parent=null, force=false)->
  parent = $('.page.visible .video') if parent==null
  if src && parent.length>0
    parent.each(()->
      currentVideo = $(this).find('video')[0]
      if currentVideo?
        currentVideo.setAttribute("poster", src.poster) if src.poster
        if Modernizr.touchevents && Modernizr.video && Modernizr.video.h264 && src.mp4
          currentVideo.setAttribute("src", src.mp4)
        else if(Modernizr.video && Modernizr.video.webm && src.webm)
          currentVideo.setAttribute("src", src.webm)
        else if(Modernizr.video && Modernizr.video.ogg && src.ogg)
          currentVideo.setAttribute("src", src.ogg)
        else if Modernizr.video && Modernizr.video.h264 && src.mp4
          currentVideo.setAttribute("src", src.mp4)
        currentVideo.load()
    )
  else
    src = {}
    if currentVideo
      src.webm = getVideoSource()
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
    thumbnail =
      if (relatedItem.thumbnail? && relatedItem.thumbnail!="")
      then relatedItem.thumbnail
      else "assets/images/thumbnail.jpg"
    if currentVideo? && !isNaN(currentVideo.duration)
      time = formatTime.timeToMiliSeconds(relatedItem.startTime)
      p = Math.ceil(time/Math.ceil(currentVideo.duration*1000) * 100)
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
        <a data-index="#{index}" title="#{relatedItem.title}">
          <div class="img"><img src="#{thumbnail}"></div>
          <div class="info">#{relatedItem.title}</div>
        </a>
      </li>
    """
  if currentVideo? && !isNaN(currentVideo.duration)
    relatedItemsContainer.html(html)
    relatedItems = relatedItemsContainer.find('.related-item')
  relatedVideos.html(htmlList)
  relatedVideos.find('a')
    .unbind('click').bind('click',handleRelatedVideoClick)
    .unbind('mouseover').bind('mouseover', handleRelatedVideoOver)

currentVideoPlay = ()->
  $('body').addClass('is-playing')
  clearInterval(isPlayingIntervalId)
  if currentVideo
    $('.buffering').addClass('hidden')
    $(currentVideo).parent().find('.pause').addClass('hidden')
    $(currentVideo).parent().find('.play').addClass('hidden')
    $(currentVideo).parent().find('.play').removeClass('visible')
    currentVideo.play()
    previousTime = currentVideo.currentTime if currentVideo.currentTime
    video = chapterManager.getVideoFromSource(getVideoSource())
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
      $('.page.visible').find('.player-footer-container').removeClass('mini')
      setVideoControls($('.page.visible'))
      relatedItemsContainer.html('')
      relatedVideos.html('')
      $('footer').removeClass('hidden')
      $('html').removeClass('leanback')
      infoPopup.addClass('hidden')
      if currentVideo
        setCurrentTime(time)
        currentVideo.muted = $('body').hasClass('mute')
        video = chapterManager.getVideoFromSource(src.webm)
        if Modernizr.videoautoplay || (video && video.isPlayedOnce) || !Modernizr.touchevents || currentVideo.duration>0
          currentVideoPlay()
        else
          $(currentVideo).parent().find('.play').removeClass('hidden').addClass('visible')
        parsedSubtitle = null
        setRelatedItems(chapterManager.getCurrentChapterRelatedItems())
        handleWindowResize()
        loadSubtitles()
        chapterInfo.html("#{chapterManager.getCurrentChapterPlaying()+1}. #{chapterManager.getCurrentChapterTitle()}")
    )
  )
resumeVideo = ()->
  requestAnimFrame(()->
    requestAnimFrame(()->
      stop()
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

  if currentVideo && currentVideo.buffered && currentVideo.buffered.length>0
    buffered = currentVideo.buffered.end(currentVideo.buffered.length-1)/duration * 100
    bufferBar.css('width', "#{buffered}%")


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

handleVideoProgress = ()->
  updateProgress()

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
  previousTime = currentVideo.currentTime if currentVideo.currentTime
  offset = parseInt(progressBarContainer.css('padding-left'))
  x = if touch then touch.offset.x-offset else e.clientX-progressBarContainer.offset().left-offset
  updateTime(x)
  updateProgressBar()
  e.preventDefault()
  e.stopImmediatePropagation()
  return false

stopUpdateTime = (e)->
  progressBarContainer
    .unbind('mouseup')
    .unbind('tapmove')
    .unbind('tapend')
  $(window)
    .unbind('mousemove')
    .unbind('mouseup')
  currentVideoPlay() if $('body').hasClass('is-playing')
  e.preventDefault() if e

controlProgress = (e, touch)->
  if touch && ($(touch.target).hasClass('img') || $(touch.target).hasClass('info'))
    e.preventDefault()
    e.stopImmediatePropagation()
    return false
  offset = parseInt(progressBarContainer.css('padding-left'))
  x = if touch then touch.offset.x-offset else e.clientX-progressBarContainer.offset().left-offset
  currentVideoPause()
  updateTime(x)
  updateProgressBar()
  $(window)
    .unbind('mousemove').bind('mousemove', mouseMoveHandler)
    .unbind('mouseup').bind('mouseup', stopUpdateTime)
  progressBarContainer
    .unbind('mouseup').bind('mouseup', stopUpdateTime)
  if Modernizr.touchevents && browser.name != 'ie'
    progressBarContainer
      .unbind('tapmove').bind('tapmove', mouseMoveHandler)
      .unbind('tapend').bind('tapend', stopUpdateTime)
  e.preventDefault()

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
      stopShowCurrentInfo(e)
    , 400)
    e.stopImmediatePropagation()
    return false

stopShowCurrentInfo = (e)->
  infoPopup.addClass('compact') if e?.currentTarget? && $(e.currentTarget).hasClass('info-popup')
  clearTimeout(infoTimeout)
  isInfoVisible = false
  infoPopup.addClass('hidden') if infoPopup
  progressBarContainer.unbind('mousemove').unbind('mouseout')  if progressBarContainer

showCurrentInfo = (e)->
  clearTimeout(infoTimeout)
  isInfoVisible = true
  infoPopup.removeClass('hidden')
  if browser.name != 'safari'
    infoPopup.addClass('no-transition')
    requestAnimFrame(()->
      requestAnimFrame(()->
        infoPopup.removeClass('no-transition')
      )
    )
  progressBarContainer.unbind('mousemove').unbind('mouseout')
    .bind('mousemove', updateInfo).bind('mouseout', stopShowCurrentInfo)

handleInfoMouseOver = (e)->
  infoPopup.removeClass('hidden')


stopInfoPopupPropagation = (e)->
  infoPopup.removeClass('hidden')
  e.stopImmediatePropagation() if e && e.stopImmediatePropagation
  e.preventDefault() if e && e.preventDefault
  return false

togglePlay = (e)->
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
  e.preventDefault() if e && e.preventDefault
  e.stopImmediatePropagation()  if e && e.stopImmediatePropagation

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
  video = chapterManager.getVideoFromSource(getVideoSource())
  parsedSubtitle = video.parsedSubtitle
  if video? && !video.parsedSubtitle && video.subtitle?
    $.get video.subtitle, (data)->
      parsedSubtitle = video.parsedSubtitle = srtParser.fromSrt(data, true)


handleSubtitles = (e)->
  $('body').toggleClass('show-subtitles')
  ls.set(chapterManager.LOCAL_STORAGE_SHOW_SUBTITLES, $('body').hasClass('show-subtitles'))
  loadSubtitles()
  e.preventDefault()
  e.stopImmediatePropagation()

handleMute = (e)->
  $('body').toggleClass('mute')
  currentVideo.muted = !currentVideo.muted
  e.stopImmediatePropagation()

handleChaptersButtonClick = (e)->
  $('body').toggleClass('show-chapters')
  infoPopup.addClass('hidden')
  e.preventDefault()
  e.stopImmediatePropagation()

handleRelatedVideosButtonOver = ()->
#  createjs.Sound.play("over")

handleRelatedVideosButtonClick = (e)->
  infoPopup.addClass('hidden')
  $('body').removeClass('show-chapters')
  playerContainer.toggleClass('open-related-items')
  e.preventDefault()
  e.stopImmediatePropagation()

handleRelatedVideosButtonSwipeUp = (e)->
  handleRelatedVideosButtonClick(e)
  playerContainer.addClass('open-related-items')

handleRelatedVideosButtonSwipeDown = (e)->
  handleRelatedVideosButtonClick(e)
  playerContainer.removeClass('open-related-items')

handleRelatedVideoClick = ()->
#  createjs.Sound.play("click")
  playRelatedVideo($(this).data('index'))

handleRelatedVideoOver = ()->
  createjs.Sound.play("over")

handleRelatedVideosPreviousClick = ()->
  relatedVideosMask = relatedVideosContainer.find('.related-videos-mask')
  element = relatedVideosMask[0]
  nexts = relatedVideosMask.scrollLeft() - element.clientWidth
  s = if nexts>0 then nexts else 0
  relatedVideosMask.animate({
    scrollLeft: "#{s}"
  })
  
handleRelatedVideosNextClick = ()->
  relatedVideosMask = relatedVideosContainer.find('.related-videos-mask')
  element = relatedVideosMask[0]
  maxScrollLeft = element.scrollWidth - element.clientWidth
  nexts = relatedVideosMask.scrollLeft() + element.clientWidth
  s = if nexts<maxScrollLeft then nexts else maxScrollLeft
  relatedVideosMask.animate({
    scrollLeft: "#{s}"
  })

getRelatedItemsWidth = ()->
  w = 0
  relatedVideosLi = relatedVideos.find('li')
  relatedVideosLi.each(()->
    w += $(this).width()
  )
  return w+relatedVideosLi.length*10-10

handleWindowResize = ()->
  if relatedVideos.width() > getRelatedItemsWidth()
    relatedVideosContainer.addClass('no-scroll')
  else
    relatedVideosContainer.removeClass('no-scroll')


module.exports = {
  setVideoSource: setVideoSource,
  playVideo: playVideo,
  resumeVideo: resumeVideo,
  play: play,
  stop: stop
}

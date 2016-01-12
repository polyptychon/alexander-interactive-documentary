global.$ = global.jQuery = $ = require "jquery"
require "jquery-touch-events"

requestAnimFrame = require "animationframe"
chapterManager = require "./Chapters.coffee"
displayPage = require "./displayPage.coffee"
player = require "./play.coffee"
slideSound = 'page-slide-back'
archive = $('.archive')

LEFT_KEY = 37
RIGHT_KEY = 39

currentPage = 1;
pageLength = 10

bindEvents = ()->
  setTimeout(()->
    if $('.page.archive').hasClass('visible')
      $(window)
        .unbind('keyup')
        .bind('keyup', handleKeyUp)
    if ($(window).width()>1023)
      $('.archive .archive-videos-container')
      .unbind('swipeleft')
      .unbind('swiperight')
      .bind('swipeleft', previous)
      .bind('swiperight', next)
  , 1000)

init = ()->
  reset()
  bindEvents()

$('.btn.next').bind('click', ()->
  next()
)
$('.btn.previous').bind('click', ()->
  previous()
)

$('.dropdown-menu-btn').bind('click', ()->
  $(this).closest('.dropdown-menu').toggleClass('visible')
  $(this).find('.dropdown-menu').toggleClass('visible')
  $(this).parent().find('.dropdown-menu').toggleClass('visible')
)
$('.archive .related-videos a').bind('click', ()->
  $('.page.visible').addClass('slide-up')
  $('.video-player-compact').addClass('slide-down')
  SM.stopMusic('music', 1000)
  displayPage('.video-player-compact', '')
  createjs.Sound.play("page-slide-up")
  player.playVideo(chapterManager.getRelatedVideoFromIndex($(this).attr('data-index')).source)
)
$('.archive .back').bind('click', ()->
  $('.archive').removeClass('slide-up')
  reset()
  displayPage('.landing', '')
  createjs.Sound.play("page-slide-back")
)
$('.video-player-compact .back').bind('click', ()->
  displayPage('.archive', '')
  SM.playMusic('music', -1, 0)
  createjs.Sound.play("page-slide-back")
  player.stop()
  bindEvents()
)
next = ()->
  currentItems = archive.find('.related-videos li').slice(currentPage*pageLength-pageLength, pageLength*currentPage)
  nextItems = archive.find('.related-videos li').slice(currentPage*pageLength, pageLength*(currentPage+1))
  return if (nextItems.length==0)
  createjs.Sound.play(slideSound);
  animatePageChange(currentItems, nextItems)
  currentPage++
  showCurrentPage()

previous = ()->
  currentItems = archive.find('.related-videos li').slice(currentPage*pageLength-pageLength, pageLength*currentPage)
  previousItems = archive.find('.related-videos li').slice((currentPage-1)*pageLength-pageLength, pageLength*(currentPage-1))
  return if (previousItems.length==0)
  createjs.Sound.play(slideSound);
  animatePageChange(currentItems, previousItems, '')
  currentPage--
  showCurrentPage()

showCurrentPage = ()->
  archive.find('.pagination-text .page-number').html(currentPage)

width = 1000
gap = 25

sort = (direction='asc')->
  myList = archive.find('.related-videos')
  listItems = myList.children('li').get()
  listItems.sort((a, b) ->
    return $(a).find('.info').text().toUpperCase().localeCompare($(b).find('.info').text().toUpperCase())
  )
  listItems.reverse() if direction.toLowerCase()=='desc'
  $.each(listItems, (idx, itm) -> myList.append(itm) );

sortItems = (direction='asc')->
  currentPage = 1
  sort(direction)
  nextItems = archive.find('.related-videos li').slice(0, 10)
  currentItems = archive.find('.related-videos li').slice(10)
  requestAnimFrame(()->
    requestAnimFrame(()->
      animatePageChange(currentItems, nextItems, '')
      showCurrentPage()
    )
  )

$('.archive .sort-list a').bind('click', ()->
  sortItems($(this).data('sort'))
  $(this).parent().parent().find('.selected').removeClass('selected')
  $(this).addClass('selected')
  $(this).parent().parent().removeClass('visible')
  $('.archive .sort .current-sort').text($(this).text())
)

animatePageChange = (currentItems, nextItems, direction = '-') ->
  top = gap
  metr = 1
  delay = 15
  cellWidth = 150
  cellHeight = 128 + 25 -10
  currentItems.each(()->
    top = gap if (metr==1)
    $(this).css('transform', "translate(#{direction}#{width}px, #{top}px)")
    $(this).css('transition-delay', "#{delay}ms")
    delay = delay - 15
    if (metr==pageLength/2)
      top = cellHeight + gap
      delay = 75
    metr++
    metr = 1 if (metr==pageLength+1)
  )
  top = gap
  left = 0
  metr = 1
  delay = 15
  nextItems.each(()->
    top = gap if (metr==1)
    $(this).css('transform', "translate(#{left}px, #{top}px)")
    $(this).css('transition-delay', "#{delay}ms")
    left += cellWidth + gap
    delay = delay + 15
    if (metr==pageLength/2)
      top = cellHeight + gap
      left = 0
      delay = 0
    metr++
    metr = 1 if (metr==pageLength+1)
  )

reset = ()->
  currentPage = 1
  sort()
  nextItems = archive.find('.related-videos li').slice(0, 10)
  currentItems = archive.find('.related-videos li').slice(10)
  animatePageChange(currentItems, nextItems, '')
  showCurrentPage()
  $(window)
    .unbind('keyup')
  $('.archive .archive-videos-container')
    .unbind('swipeleft')
    .unbind('swiperight')

handleKeyUp = (e)->
  previous() if e.keyCode==LEFT_KEY
  next() if e.keyCode==RIGHT_KEY

init()

module.exports = {
  reset: reset
  init: init
}

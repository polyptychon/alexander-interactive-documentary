global.$ = global.jQuery = $ = require "jquery"
chapterManager = require "./Chapters.coffee"
displayPage = require "./displayPage.coffee"
player = require "./play.coffee"
slideSound = 'page-slide-back'
archive = $('.archive')

currentPage = 1;
pageLength = 10

init = ()->
  reset()

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
  nextItems = archive.find('.related-videos li').slice(0, 10)
  currentItems = archive.find('.related-videos li').slice(10)
  animatePageChange(currentItems, nextItems, '')
  showCurrentPage()

init()

module.exports = {
  reset: reset
  init: init
}

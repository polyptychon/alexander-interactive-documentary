global.$ = global.jQuery = $ = require "jquery"

$('.archive')
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
currentPage = 1;
pageLength = 10
width = 1000
gap = 25

next = ()->
  currentItems = $('.archive').find('.related-videos li').slice(currentPage*pageLength-pageLength, pageLength*currentPage)
  nextItems = $('.archive').find('.related-videos li').slice(currentPage*pageLength, pageLength*(currentPage+1))
  return if (nextItems.length==0)
  animatePageChange(currentItems, nextItems)
  currentPage++

previous = ()->
  currentItems = $('.archive').find('.related-videos li').slice(currentPage*pageLength-pageLength, pageLength*currentPage)
  previousItems = $('.archive').find('.related-videos li').slice((currentPage-1)*pageLength-pageLength, pageLength*(currentPage-1))
  return if (previousItems.length==0)
  animatePageChange(currentItems, previousItems, '')
  currentPage--

animatePageChange = (currentItems, nextItems, direction = '-') ->
  top = gap
  left = 0
  metr = 1
  delay = 15
  currentItems.each(()->
    $(this).css('transform', "translate(#{direction}#{width}px, #{top}px)")
    $(this).css('transition-delay', "#{delay}ms")
    delay = delay - 15
    if (metr==pageLength/2)
      top = 150 + gap
      delay = 75
    metr++
  )
  top = gap
  left = 0
  metr = 1
  delay = 15
  nextItems.each(()->
    $(this).css('transform', "translate(#{left}px, #{top}px)")
    $(this).css('transition-delay', "#{delay}ms")
    left += 150 + gap
    delay = delay + 15
    if (metr==pageLength/2)
      top = 150 + gap
      left = 0
      delay = 0
    metr++
  )

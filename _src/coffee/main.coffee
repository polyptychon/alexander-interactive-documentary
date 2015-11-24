global.$ = global.jQuery = $ = require "jquery"

require "select2"
require "bootstrap/assets/javascripts/bootstrap/transition"
require "bootstrap/assets/javascripts/bootstrap/affix"
require "bootstrap/assets/javascripts/bootstrap/tab"
require "bootstrap/assets/javascripts/bootstrap/dropdown"
require "bootstrap/assets/javascripts/bootstrap/collapse"
require "bootstrap/assets/javascripts/bootstrap/carousel"
require "./jquery.mobile.custom"
require "./highlight"

getQueryString = require "./getQueryString"
search = getQueryString('search')
console.log(search)
$(".collection-list").highlight(search) if (search!="")

#contact form
if ($('form.sent').length>0)
  $('.screen-reader-response').addClass('alert-success')


#photoswipe
initPhotoSwipe = require "./init-photoswipe.coffee"
initPhotoSwipe(".content-photos.photos a", ".image-container") if $(".content-photos.photos a").length>0
initPhotoSwipe(".home-photos.photos a.icon-fullscreen-image", ".image-container") if $(".home-photos.photos a.icon-fullscreen-image").length>0
initPhotoSwipe(".carousel-inner .item-image", ".item-image") if $(".carousel-inner .item-image").length>0

$(".content-html a > img").each(()->
  $(this).parent().addClass("cboxElement");
)
initPhotoSwipe(".content-html a.cboxElement", ".content-html a.cboxElement") if $(".content-html a.cboxElement").length>0



# carousel
carousel = $("#carousel-generic")

if 'ontouchstart' of window
  document.documentElement.className = document.documentElement.className + ' touch'

carousel.carousel({interval: 2000000}) if (carousel.length>0)

if (carousel.length>0)
  carousel.on('swiperight', ()->
    $(this).carousel('prev')
  )
  carousel.on('swipeleft', ()->
    $(this).carousel('next')
  )

#select
select2 = $('.collection-search select')
select2.select2()

select2.bind('change', (e)->
  $(this).closest('form').submit()
)

#filters
$('.toggle-filters').click(()->
  $('.collection-search').toggleClass('open')
)

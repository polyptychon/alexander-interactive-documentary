global.$ = global.jQuery = $ = require "jquery"

$('.btn.next').bind('click', ()->
  $('.related-videos-container').removeClass('page1')
  $('.related-videos-container').addClass('page2')
)
$('.btn.previous').bind('click', ()->
  $('.related-videos-container').removeClass('page2')
  $('.related-videos-container').addClass('page1')
)

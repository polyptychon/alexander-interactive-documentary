global.$ = global.jQuery = $ = require "jquery"
away = require('away')

$('.chapters-btn').bind('click', (e)->
  $('body').toggleClass('show-chapters')
)
$('.chapters .back').bind('click', (e)->
  $('body').toggleClass('show-chapters')
)
$('.related-items-btn').bind('click', (e)->
  $('body').removeClass('show-chapters')
  $('.player-footer-container').toggleClass('open-related-items')
)

timer = away(10000)
timer.on 'idle', ()-> toggleMiniBar()
timer.on 'active', ()-> toggleMiniBar()

miniInterval = -1;
toggleMiniBar = ()->
  return if (!$('body').hasClass('is-playing'))
  $('body').removeClass('show-chapters')
  $('.player-footer-container').removeClass('open-related-items')
  $('.player-footer-container').removeClass('completed')
  $('.player-footer-container').toggleClass('mini')
  $('footer').toggleClass('hidden')
  clearInterval(miniInterval);
  miniInterval = setInterval(()->
    $('.player-footer-container').addClass('completed')
  , 300) if $('.player-footer-container').hasClass('mini')

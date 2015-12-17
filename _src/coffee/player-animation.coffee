global.$ = global.jQuery = $ = require "jquery"
away = require('away')

$('.related-items-btn').bind('click', (e)->
  $('.info-popup').addClass('hidden')
  $('body').removeClass('show-chapters')
  $('.player-footer-container').toggleClass('open-related-items')
)

timer = away(10000)
timer.on 'idle', ()-> hideMiniBar()
timer.on 'active', ()-> showMiniBar()

miniInterval = -1;
hideMiniBar = ()->
  return if (!$('body').hasClass('is-playing'))
  $('body').removeClass('show-chapters')
  $('.player-footer-container').removeClass('open-related-items')
  $('.player-footer-container').removeClass('completed')
  $('.player-footer-container').addClass('mini')
  $('html').addClass('leanback')
  $('footer').addClass('hidden')
  $('.info-popup').addClass('hidden')
  clearInterval(miniInterval);
  miniInterval = setInterval(()->
    $('.player-footer-container').addClass('completed')
  , 300) if $('.player-footer-container').hasClass('mini')

showMiniBar = ()->
  $('body').removeClass('show-chapters')
  $('.player-footer-container').removeClass('open-related-items')
  $('.player-footer-container').removeClass('completed')
  $('.player-footer-container').removeClass('mini')
  $('html').removeClass('leanback')
  $('footer').removeClass('hidden')
  clearInterval(miniInterval);

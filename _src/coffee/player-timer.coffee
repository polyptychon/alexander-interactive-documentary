global.$ = global.jQuery = $ = require "jquery"
away = require('away')

timer = away(10000)
timer.on 'idle', ()-> hideMiniBar()
timer.on 'active', ()-> showMiniBar()

miniTimeout = -1;

hideMiniBar = ()->
  return if (!$('body').hasClass('is-playing'))
  $('body').removeClass('show-chapters')
  $('.player-footer-container').removeClass('open-related-items')
  $('.player-footer-container').removeClass('completed')
  $('.player-footer-container').addClass('mini')
  $('html').addClass('leanback')
  $('footer').addClass('hidden')
  $('.info-popup').addClass('hidden')
  clearTimeout(miniTimeout);
  miniTimeout = setTimeout(()->
    $('.player-footer-container').addClass('completed')
  , 300) if $('.player-footer-container').hasClass('mini')

showMiniBar = ()->
  $('body').removeClass('show-chapters')
  $('.player-footer-container').removeClass('open-related-items')
  $('.player-footer-container').removeClass('completed')
  $('.player-footer-container').removeClass('mini')
  $('html').removeClass('leanback')
  $('footer').removeClass('hidden')
  clearTimeout(miniTimeout);

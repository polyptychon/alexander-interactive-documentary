global.$ = global.jQuery = $ = require "jquery"

require "select2"
require "bootstrap/assets/javascripts/bootstrap/transition"
require "bootstrap/assets/javascripts/bootstrap/affix"
require "bootstrap/assets/javascripts/bootstrap/tab"
require "bootstrap/assets/javascripts/bootstrap/dropdown"
require "bootstrap/assets/javascripts/bootstrap/collapse"
require "bootstrap/assets/javascripts/bootstrap/carousel"
away = require('away')

$('.chapters-btn').bind('click', (e)->
  $('body').toggleClass('show-chapters')
  e.stopImmediatePropagation()
  return false
)
$('.chapters .back').bind('click', (e)->
  $('body').toggleClass('show-chapters')
  e.stopImmediatePropagation()
  return false
)
$('.related-items-btn').bind('click', (e)->
  $('.player-footer-container').toggleClass('open-related-items')
  e.stopImmediatePropagation()
  return false
)
miniInterval = -1;
#$('body').bind('click', (e)->
#  toggleMiniBar()
#)

timer = away(10000)
timer.on 'idle', ()-> toggleMiniBar()
timer.on 'active', ()-> toggleMiniBar()

toggleMiniBar = ()->
  $('body').removeClass('show-chapters')
  $('.player-footer-container').removeClass('open-related-items')
  $('.player-footer-container').removeClass('completed')
  $('.player-footer-container').toggleClass('mini')
  clearInterval(miniInterval);
  miniInterval = setInterval(()->
    $('.player-footer-container').addClass('completed')
  , 200) if $('.player-footer-container').hasClass('mini')

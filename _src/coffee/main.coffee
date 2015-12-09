global.$ = global.jQuery = $ = require "jquery"

require "select2"
require "bootstrap/assets/javascripts/bootstrap/transition"
require "bootstrap/assets/javascripts/bootstrap/affix"
require "bootstrap/assets/javascripts/bootstrap/tab"
require "bootstrap/assets/javascripts/bootstrap/dropdown"
require "bootstrap/assets/javascripts/bootstrap/collapse"
require "bootstrap/assets/javascripts/bootstrap/carousel"

isTouchDevice =  require "./detectTouchDevice"
$('html').addClass('hasTouch') if isTouchDevice()

require "./player-animation.coffee"
require "./archive-animation.coffee"
pageTimeoutId = -1;
displayPage = (previousPage, nextPage, background)->
  clearTimeout(pageTimeoutId);
  $(previousPage).removeClass('visible')
  $(nextPage).addClass('visible').css('background-image', "url(#{background})")
  pageTimeoutId = setTimeout(()->
    $(previousPage).addClass('hidden')
    $(nextPage).removeClass('hidden')
  ,1000)

handleLoadComplete = ()->
  displayPage('.preloader', '.landing', queue.getItem("landing-bg").src)

$('.play-documentary-btn').bind('click', ()->
  displayPage('.landing', '.chapter', queue.getItem("chapter-1-bg").src)
  pageTimeoutId = setTimeout(()->
    displayPage('.chapter', '.video-player', queue.getItem("hades").src)
  ,4000)
)
$('.btn-footer.btn-home').bind('click', ()->
  activeClassName = '.'+$('body > .visible').attr('class').replace(' visible', '')
  displayPage(activeClassName, '.landing', queue.getItem("landing-bg").src)
)
queue = require("./preload-assets.coffee")(handleLoadComplete)

$('.dropdown-menu-btn').bind('click', ()->
  $(this).closest('.dropdown-menu').toggleClass('visible')
  $(this).find('.dropdown-menu').toggleClass('visible')
  $(this).parent().find('.dropdown-menu').toggleClass('visible')
)

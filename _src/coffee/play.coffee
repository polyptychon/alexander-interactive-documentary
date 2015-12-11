displayPage = require "./displayPage.coffee"
pageTimeoutId = -1

module.exports = {
  play: (chapter, time, chapterBg)->
    clearTimeout(pageTimeoutId)
    displayPage('.chapter', chapterBg)
    $('.player-footer-container').addClass('mini')
    pageTimeoutId = setTimeout(()->
      createjs.Sound.stop("music");
      $('body').addClass('is-playing')
      $('.player-footer-container').removeClass('mini')
      displayPage('.video-player', chapterBg)
    , 4000)
  stop: ()->
    clearTimeout(pageTimeoutId)
    $('body').removeClass('is-playing')
}

displayPage = require "./displayPage.coffee"
require "./SoundWrapper"

pageTimeoutId = -1

module.exports = {
  play: (chapter, time, chapterBg)->
    clearTimeout(pageTimeoutId)
    displayPage('.chapter', 'cross-dissolve', chapterBg)
    $('.player-footer-container').addClass('mini')
    pageTimeoutId = setTimeout(()->
      SM.stopMusic('music', 6000)
      $('body').addClass('is-playing')
      $('.player-footer-container').removeClass('mini')
      displayPage('.video-player')
    , 4000)
  stop: ()->
    clearTimeout(pageTimeoutId)
    $('body').removeClass('is-playing')
    SM.playMusic('music', -1, 3000)
}

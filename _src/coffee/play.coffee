displayPage = require "./displayPage.coffee"
pageTimeoutId = -1
module.exports = (chapter, time, chapterBg)->
  clearTimeout(pageTimeoutId)
  displayPage('.chapter', chapterBg)
  pageTimeoutId = setTimeout(()->
    $('body').addClass('is-playing')
    displayPage('.video-player', chapterBg)
  ,4000)

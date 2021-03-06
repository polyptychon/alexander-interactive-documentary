chapterManager = require "./chapters.coffee"
requestAnimFrame = require "animationframe"
browser = require "detect-browser"
ls = require "local-storage"
pageTimeoutId = -1

module.exports = (nextPage, effe='cross-dissolve', background=null)->
  clearTimeout(pageTimeoutId);
  $(nextPage).css('display', 'block')

  requestAnimFrame(()->
    requestAnimFrame(()->
      $('.buffering').addClass('hidden')
      $('.pause').addClass('hidden')
      $('.play').addClass('hidden')
      $('.page').addClass('hidden') if (effe!='cross-dissolve')
      $('.page.visible').each(()-> $(this).removeClass('visible'))
      $(nextPage).removeClass('hidden').addClass('visible')
      $(nextPage).find('.bg').css('background-image', "url(#{background})") if (background)
      if browser.name != "ie" && ls.get(chapterManager.LOCAL_STORAGE_CHAPTER)>0 || ls.get(chapterManager.LOCAL_STORAGE_TIME)>60
        $('.intro-play-buttons').addClass('resume')
      else
        $('.intro-play-buttons').removeClass('resume')
      pageTimeoutId = setTimeout(()->
        $('.page').addClass('hidden') if (effe=='cross-dissolve')
        $(nextPage).removeClass('hidden')
        $(nextPage).css('display', 'block')
        $('.page.hidden').css('display', 'none')
      ,1000)
    )
  )

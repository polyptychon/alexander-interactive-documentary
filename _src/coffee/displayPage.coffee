chapterManager = require "./chapters.coffee"
requestAnimFrame = require("animationframe")
ls = require 'local-storage'

pageTimeoutId = -1;
module.exports = (nextPage, effe='cross-dissolve', background=null)->
  clearTimeout(pageTimeoutId);
  $(nextPage).css('display', 'block')

  requestAnimFrame(()->
    requestAnimFrame(()->
      $('.page').addClass('hidden') if (effe!='cross-dissolve')
      $('body > .visible').each(()-> $(this).removeClass('visible'))
      $(nextPage).removeClass('hidden').addClass('visible')
      $(nextPage).find('.bg').css('background-image', "url(#{background})") if (background)
      if ls.get(chapterManager.LOCAL_STORAGE_CHAPTER)>0 || ls.get(chapterManager.LOCAL_STORAGE_TIME)>60
        $('.intro-play-buttons').addClass('resume')
      else
        $('.intro-play-buttons').removeClass('resume')
      pageTimeoutId = setTimeout(()->
        $('.page').addClass('hidden') if (effe=='cross-dissolve')
        $(nextPage).removeClass('hidden')
        $('body > .hidden').css('display', 'none')
      ,1000)
    )
  )

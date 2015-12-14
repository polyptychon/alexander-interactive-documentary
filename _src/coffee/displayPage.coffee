pageTimeoutId = -1;
module.exports = (nextPage, effe='cross-dissolve', background=null)->
  clearTimeout(pageTimeoutId);
  $('.page').addClass('hidden') if (effe!='cross-dissolve')
  $('body > .visible').each(()-> $(this).removeClass('visible'))
  $(nextPage).removeClass('hidden').addClass('visible')
  $(nextPage).find('.bg').css('background-image', "url(#{background})") if (background)
  pageTimeoutId = setTimeout(()->
    $('.page').addClass('hidden') if (effe=='cross-dissolve')
    $(nextPage).removeClass('hidden')
  ,1000)

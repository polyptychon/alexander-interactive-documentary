pageTimeoutId = -1;
module.exports = (nextPage, background, effe='cross-dissolve')->
  previousPage = '.'+$('body > .visible').attr('class').replace(' visible', '')
  clearTimeout(pageTimeoutId);
  $(previousPage).addClass('hidden') if (effe!='cross-dissolve')
  $(previousPage).removeClass('visible')
  $(nextPage).addClass('visible').css('background-image', "url(#{background})")
  pageTimeoutId = setTimeout(()->
    $(previousPage).addClass('hidden') if (effe=='cross-dissolve')
    $(nextPage).removeClass('hidden')
  ,1000)

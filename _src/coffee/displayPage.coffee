pageTimeoutId = -1;
module.exports = (nextPage, background, effe='cross-dissolve')->
  clearTimeout(pageTimeoutId);
  $('.page').addClass('hidden') if (effe!='cross-dissolve')
  $('body > .visible').each(()-> $(this).removeClass('visible'))
  $(nextPage).removeClass('hidden').addClass('visible').find('.bg').css('background-image', "url(#{background})")
  pageTimeoutId = setTimeout(()->
    $('.page').addClass('hidden') if (effe=='cross-dissolve')
    $(nextPage).removeClass('hidden')
  ,1000)

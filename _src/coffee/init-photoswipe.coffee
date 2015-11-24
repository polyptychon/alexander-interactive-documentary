PhotoSwipe = require "photoswipe"
PhotoSwipeUI_Default = require "photoswipe/dist/photoswipe-ui-default"

getAttr = (element, attr, d) ->
  return element.attr(attr) if (element.length>0 && element.attr(attr)?)
  return element.find("img").attr(attr) if (element.length>0 && element.find("img").length>0 && element.find("img").attr(attr)?)
  return d


module.exports = (target, elementRepeater, defaultWidth = 2160, defaultHeight = 1440)->
  pswpTargetElements = $(target)
  src = require "./photoswipe-template.jade"
  $("body").append(src)

  pswpElement = document.querySelectorAll('.pswp')[0];

  items = []
  pswpTargetElements.each(()->
    w = getAttr($(this), "data-width", defaultWidth)
    h = getAttr($(this), "data-height", defaultHeight)
    c = getAttr($(this), "data-caption", null)
    items.push({
      image: {
        src: $(this).attr("href")
        title: c
        w: w
        h: h
      },
      retinaImage: {
        src: if ($(this).attr("data-retina-image")?) then $(this).attr("data-retina-image") else $(this).attr("href")
        title: c
        w: if ($(this).attr("data-retina-width")?) then parseInt($(this).attr("data-retina-width"), 10) else w
        h: if ($(this).attr("data-retina-height")?) then parseInt($(this).attr("data-retina-height"), 10) else h
      }
    })
  )
  realViewportWidth = null
  useLargeImages = false
  firstResize = true
  imageSrcWillChange = false

  openPhotoSwipe = (img, index)->
    options = {
      index: index

      history: false
      barsSize: {top:0, bottom:0},
      focus: true
      showHideOpacity: true
      bgOpacity: 1
#      maxSpreadZoom: 1

      getThumbBoundsFn: (index)->
        thumbnail = img[0]
        pageYScroll = window.pageYOffset || document.documentElement.scrollTop
        rect = thumbnail.getBoundingClientRect();

        return {x:rect.left, y:rect.top + pageYScroll, w:rect.width};
    }
    setNextPreviousButtons = ()->
      return;
      container = $(gallery.currItem.container)
      img = container.find("img", "img.wrap-image")
      container.append("<div class=\"previous\" style=\"width:#{img.width()/2}px; height: #{img.height()}px; left:0px; \"></div>")
      container.append("<div class=\"next\" style=\"width: #{img.width()/2}px; height: #{img.height()}px; left:#{img.width()/2}px;\"></div>")

      container.find(".previous").bind("click", (e)->
        gallery.prev() if (!gallery.isDragging() && !gallery.isMainScrollAnimating())
      )
      container.find(".next").bind("click", (e)->
        gallery.next() if (!gallery.isDragging() && !gallery.isMainScrollAnimating())
      )

    gallery = new PhotoSwipe( pswpElement, PhotoSwipeUI_Default, items, options)
    gallery.listen('afterChange', ()->
      setNextPreviousButtons()
    )
    gallery.listen('imageLoadComplete', (index, item)->
      setTimeout(()->
        setNextPreviousButtons()
      , 500)
    )
    gallery.listen('initialZoomOut', ()->
      return;
      $(".pswp__item").find(".next").remove()
      $(".pswp__item").find(".previous").remove()
    )
    gallery.listen('beforeResize', ()->
      realViewportWidth = gallery.viewportSize.x * window.devicePixelRatio

      if(useLargeImages && realViewportWidth < (768*2))
        useLargeImages = false;
        imageSrcWillChange = true;
      else if(!useLargeImages && realViewportWidth >= (768*2))
        useLargeImages = true;
        imageSrcWillChange = true;

      gallery.invalidateCurrItems() if(imageSrcWillChange && !firstResize)
      firstResize = false if(firstResize)
      imageSrcWillChange = false
    )
    gallery.listen('gettingData', (index, item)->
      if( useLargeImages )
        item.src = item.retinaImage.src
        item.title = item.retinaImage.title
        item.w = item.retinaImage.w
        item.h = item.retinaImage.h
      else
        item.src = item.image.src
        item.title = item.image.title
        item.w = item.image.w
        item.h = item.image.h
    )
    gallery.init()

  pswpTargetElements.each((index)->
    $(this).bind("click", (e)->
      img = $(this).closest(elementRepeater).find("img", "img.wrap-image");
      openPhotoSwipe(img, index)
      e.preventDefault()
      return false
    )
  )



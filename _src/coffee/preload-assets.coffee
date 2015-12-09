global.$ = global.jQuery = $ = require "jquery"
require "preloadjs/lib/preloadjs-0.6.2.min"
preloader = require "./preloader";

module.exports = (callback=null)->
  handleCompleteAnimation = () ->
    $('.preloader').css('opacity', 0)
    $('.landing').css('background-image', "url(#{queue.getItem("landing-bg").src})")
    $('.landing').addClass('visible')
    callback() if callback

  handleProgress = (e) -> preloader(e.progress, handleCompleteAnimation)
  queue = new createjs.LoadQueue()
  queue.installPlugin(createjs.Sound)
  #queue.on("complete", handleComplete, this)
  queue.on("progress", handleProgress, this)
  queue.loadManifest([
    { id: "landing-bg", src: "assets/images/alexander.jpg" }
    { id: "chapter-1-bg", src: "assets/images/stone-light.jpg" }
    { id: "alexanderPlain", src: "assets/images/alexander-plain.jpg" }
    { id: "hades", src: "assets/images/hades.jpg" }
    { id: "mosaic", src: "assets/images/mosaic.jpg" }
    { id: "stone", src: "assets/images/stone.jpg" }
    { id: "stoneDark", src: "assets/images/stone-dark.jpg" }
    { id: "stoneLight", src: "assets/images/stone-light.jpg" }
    { id: "thumbnail", src: "assets/images/thumbnail.jpg" }
  ])
  return queue

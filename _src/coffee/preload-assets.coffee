global.$ = global.jQuery = $ = require "jquery"
require "preloadjs/lib/preloadjs-0.6.2.min"
preloader = require "./preloader";

handleCompleteAnimation = () ->
  $('.preloader').css('opacity', 0)
  $('.landing').css('background-image', "url(#{queue.getItem("alexander").src})")
  $('.landing').css('opacity', 1)
  
handleProgress = (e) -> preloader(e.progress, handleCompleteAnimation)
#handleComplete = (e) -> console.log(queue.getResult("alexander"))

queue = new createjs.LoadQueue()
queue.installPlugin(createjs.Sound)
#queue.on("complete", handleComplete, this)
queue.on("progress", handleProgress, this)
queue.loadManifest([
  { id: "alexander", src: "assets/images/alexander.jpg" }
  { id: "alexanderPlain", src: "assets/images/alexander-plain.jpg" }
  { id: "hades", src: "assets/images/hades.jpg" }
  { id: "mosaic", src: "assets/images/mosaic.jpg" }
  { id: "stone", src: "assets/images/stone.jpg" }
  { id: "stoneDark", src: "assets/images/stone-dark.jpg" }
  { id: "stoneLight", src: "assets/images/stone-light.jpg" }
  { id: "thumbnail", src: "assets/images/thumbnail.jpg" }
])

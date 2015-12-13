global.$ = global.jQuery = $ = require "jquery"
require "./preloadjs-0.6.2.min"
require "./soundjs-0.6.2.min"
preloader = require "./preloader";

module.exports = (callback=null)->
  handleCompleteAnimation = () ->
    callback() if callback

  handleProgress = (e) -> preloader(e.progress, handleCompleteAnimation)
  queue = new createjs.LoadQueue()
  queue.installPlugin(createjs.Sound)
#  queue.on("complete", handleComplete, this)
  queue.on("progress", handleProgress, this)
#  queue.loadFile({id:"music", src:"assets/sounds/soundtrack.mp3"});
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

#    {id:"music", src:"assets/sounds/soundtrack.mp3"}
    {id:"click", src:"assets/sounds/FX_Click_1.mp3"}
    {id:"over", src:"assets/sounds/FX_GenericMouseOver.mp3"}
    {id:"page-slide-back", src:"assets/sounds/FX_DossierPageSlideBack_1.mp3"}
    {id:"page-slide-up", src:"assets/sounds/FX_DossierPageSlideUp_1.mp3"}
    {id:"archive-slide", src:"assets/sounds/FX_TimelineMenuIn_1.mp3"}
  ])
  return queue

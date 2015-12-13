require("./soundjs-0.6.2.min");

global.SM = (function(){
  var play = require("play-audio");
  var musics = {};
  /**
   * CreateJS Sound Manager
   * @returns {null}
   */
  function SM(){
    throw new Error("This class can't be instantiated");
    return null;
  }

  /**
   * Play music. This is only for playing musics. Use SM.playSound to play sound effects
   * @static
   * @param {String} id
   * @param {Number} repeat Number of times to repeat,0-once,-1-loop @default 0
   * @param {Number} fadeIn Number of milliseconds to fade in
   * @returns {void}
   */
  SM.playMusic = function(id,repeat,fadeIn){
    if(musics[id] && musics[id].playing){
      return;
    }
    repeat = repeat||0;
    fadeIn = (!fadeIn)?0:fadeIn;
    var instance = null;
    if (id=='music') {
      instance = play('assets/sounds/soundtrack.mp3').volume(1).loop().play();
      instance.volume((fadeIn !== 0) ? 0 : 1);
      var o = {
        instance: instance,
        playing: true,
        repeat: (repeat >= 0) ? repeat : 0,
        loop: (repeat === -1) ? true : false,
        fadeStep: 1000 / (60 * fadeIn),
        fadeType: "FADE_IN"
      };
      musics[id] = o;
      instance.on("complete", function () {
        SM.musicComplete(o);
      });
    } else {
      instance = createjs.Sound.play(id);
      instance.volume = (fadeIn !== 0) ? 0 : 1;
      var o = {
        instance: instance,
        playing: true,
        repeat: (repeat >= 0) ? repeat : 0,
        loop: (repeat === -1) ? true : false,
        fadeStep: 1000 / (60 * fadeIn),
        fadeType: "FADE_IN"
      };
      musics[id] = o;
      instance.addEventListener("complete", function () {
        SM.musicComplete(o);
      });
    }
  };
  SM.update = function(){
    for(var id in musics){
      var o = musics[id];
      if(!isNaN(o.fadeStep) && o.playing){
        if(o.fadeType === "FADE_IN"){
          if (id=="music") {
            if(o.fadeStep + o.instance.volume() >= 1){
              o.instance.volume(1);
            } else {
              o.instance.volume(o.fadeStep + o.instance.volume());
            }
          } else {
            o.instance.volume += o.fadeStep;
            if(o.instance.volume >= 1){
              o.instance.volume = 1;
            }
          }
        }else{
          if (id=="music") {
            if( o.instance.volume() - o.fadeStep <= 0){
              o.playing = false;
              o.instance.volume(0);
              o.instance.pause().currentTime(0);
            } else {
              o.instance.volume(o.instance.volume()-o.fadeStep);
            }
          } else {
            o.instance.volume -= o.fadeStep;
            if(o.instance.volume <= 0){
              o.instance.volume = 0;
              o.playing = false;
              SM.stopMusic(id);
            }
          }
        }
      }
    }
  };
  SM.musicComplete = function(o){
    o.playing = false;
    o.repeat -= 1;
    if(o.loop===true){
      o.instance.play();
      o.playing = true;
    }else if(o.repeat>0){
      o.instance.play();
      o.playing = true;
    }
  };
  /**
   * Stop a playing music
   * @static
   * @param {String} id
   * @param {Number}  fadeOut Number of milliseconds to fadeOut
   * @returns {void}
   */
  SM.stopMusic = function(id,fadeOut){
    var o = musics[id];
    fadeOut = (!fadeOut)?0:fadeOut;
    if(o && o.playing){
      o.fadeType = "FADE_OUT";
      if (id=="music") {
        o.fadeStep = (o.instance.volume()*1000)/(60*fadeOut);
      } else {
        o.fadeStep = (o.instance.volume*1000)/(60*fadeOut);
      }
    }
  };
  /**
   * Play a sound. Use this only to play a sound effect. If it is music, use CSM.playMusic instead
   * @param {String} id
   * @returns {void}
   */
  SM.playSound = function(id){
    createjs.Sound.play(id);
  };
  /**
   * Stop a sound
   * @param {String} id
   * @returns {void}
   */
  SM.stopSound = function(id){
    createjs.Sound.stop(id);
  };
  /**
   * Stop playing all sounds
   * @param {type} fadeOut
   * @returns {void}
   */
  SM.stopAllMusics = function(fadeOut){
    for(var id in musics){
      SM.stopMusic(id,fadeOut);
    }
  };

  return SM;
})();

var intervalID = setInterval(function() {
  SM.update();
}, 100/60);

window.requestAnimFrame = (function () {
  return  window.requestAnimationFrame ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    function (callback) {
      window.setTimeout(callback, 1000 / 60);
    };
})();
var previousProgress = 0;
module.exports = function(progress, callback) {
  progress = Math.ceil(360 * progress);
  var canvas = document.getElementById('preloader'),
    width = canvas.width,
    height = canvas.height,
    ctx = canvas.getContext('2d'),
    imd = null;

  var step = -90,
    startAngle = -90,
    endAngle = progress+(startAngle*2);

  var x = width / 2, // center x
    y = height / 2, // center y
    radius = width / 3,
    counterClockwise = false;

  ctx.beginPath();
  ctx.imageSmoothingEnabled = true;
  ctx.lineWidth = 0;
  ctx.fillStyle = '#221e1a';
  ctx.strokeStyle = '#221e1a';
  ctx.lineCap = 'square';
  ctx.closePath();
  ctx.fill();

  imd = ctx.getImageData(0, 0, width, height);

  function draw() {
    drawArc(startAngle * Math.PI/180, step * Math.PI/180);
    step+=4;
  }
  function drawArc(s, e) {
    ctx.clearRect(0,0,width, height);

    ctx.fillStyle = 'rgba(34,30,26,.4)';
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.arc(x, y, radius, s, 275 * Math.PI/180, counterClockwise);
    ctx.fill();

    ctx.fillStyle = '#221e1a';
    ctx.strokeStyle = '#221e1a';

    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.arc(x, y, radius, s, previousProgress * Math.PI/180, counterClockwise);
    ctx.fill();

    previousProgress = progress;
    ctx.putImageData(imd, 0, 0);
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.arc(x, y, radius, s, e, counterClockwise);
    ctx.fill();
  }

  window.requestAnimFrame = (function () {
    return  window.requestAnimationFrame ||
      window.webkitRequestAnimationFrame ||
      window.mozRequestAnimationFrame ||
      window.oRequestAnimationFrame ||
      window.msRequestAnimationFrame ||
      function (callback) {
        window.setTimeout(callback, 1000 / 60);
      };
  })();

  (function onEnterFrame() {
    draw();
    if (step <= endAngle-startAngle) {
      requestAnimFrame(onEnterFrame, canvas);
    } else if (step>=274) {
      callback();
    }
  }());
};

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

module.exports = function(progress) {
  progress = 360*progress
  var canvas = document.getElementById('preloader'),
    width = canvas.width,
    height = canvas.height,
    ctx = canvas.getContext('2d')
    imd = null;

  var step = -90,
    startAngle = -90,
    endAngle = progress+(startAngle*2);

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
    if (step <= endAngle-startAngle) {
      drawArc(startAngle * Math.PI/180, step * Math.PI/180);
      step+=2;
    }
  }
  function drawArc(s, e) {
    var x = width / 2, // center x
      y = height / 2, // center y
      radius = width / 3,
      counterClockwise = false;

    ctx.closePath();
    ctx.fill();

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
    requestAnimFrame(onEnterFrame, canvas);
  }());
}

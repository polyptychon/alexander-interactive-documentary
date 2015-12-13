var requestAnimFrame = require("animationframe");
var previousProgress = 0;

var canvas = document.getElementById('preloader'),
  width = canvas.width,
  height = canvas.height,
  ctx = canvas.getContext('2d'),
  progress = 0;

var step = 0,
  startAngle = 0,
  endAngle = 0;

var x = width / 2, // center x
  y = height / 2, // center y
  radius = width / 3,
  counterClockwise = false;

ctx.imageSmoothingEnabled = true;
ctx.lineWidth = 0;
ctx.fillStyle = '#221e1a';
ctx.strokeStyle = '#221e1a';
ctx.lineCap = 'square';

function draw() {
  drawArc(startAngle * Math.PI/180 - 90 * Math.PI/180, step * Math.PI/180 - 90 * Math.PI/180);
  if (step<endAngle) {
    step += 4;
  }
}
function drawArc(s, e) {
  ctx.clearRect(0,0,width, height);

  ctx.fillStyle = 'rgba(34,30,26,.4)';
  ctx.beginPath();
  ctx.moveTo(x, y);
  ctx.arc(x, y, radius, s, 360 * Math.PI/180, counterClockwise);
  ctx.fill();

  ctx.fillStyle = '#221e1a';
  ctx.strokeStyle = '#221e1a';

  ctx.beginPath();
  ctx.moveTo(x, y);
  ctx.arc(x, y, radius, s, e, counterClockwise);
  ctx.fill();
}
function onEnterFrame() {
  draw();
  if (step<360) {
    requestAnimFrame(onEnterFrame, ctx);
  } else {
    callback();
  }
}
onEnterFrame();

module.exports = function(progress, c) {
  progress = Math.ceil(360 * progress);
  endAngle = progress;
  callback = c;
};

var requestAnimFrame = require("animationframe");

var canvas = document.getElementById('preloader'),
  width = canvas.width,
  height = canvas.height,
  ctx = canvas.getContext('2d'),
  progress = 0;

var step = 0,
  percent = 0,
  startAngle = 0,
  endAngle = 0;

var x = width / 2, // center x
  y = height / 2, // center y
  radius = width / 3,
  counterClockwise = false;

ctx.imageSmoothingEnabled = true;
ctx.lineWidth = 0;
ctx.lineCap = 'square';

function degreesToRadians(degrees) {
  return degrees * Math.PI/180;
}
function draw() {
  drawArc(degreesToRadians(startAngle-90), degreesToRadians(step-90));
  if (step<endAngle) {
    step += 4;
    percent = Math.ceil(step/360*100);
  }
}
function drawArc(s, e) {
  ctx.clearRect(0,0,width, height);

  ctx.fillStyle = 'rgba(34,30,26,.4)';
  ctx.beginPath();
  ctx.moveTo(x, y);
  ctx.arc(x, y, radius, s, degreesToRadians(360), counterClockwise);
  ctx.fill();

  ctx.fillStyle = '#221e1a';
  ctx.strokeStyle = '#221e1a';

  ctx.beginPath();
  ctx.moveTo(x, y);
  ctx.arc(x, y, radius, s, e, counterClockwise);
  ctx.fill();

  ctx.fillStyle = 'rgba(255,255,255,.2)';
  ctx.font = "24px ProximaNova center";
  ctx.textAlign = "center";
  ctx.fillText(percent.toString(), 50, 57);
}
function onEnterFrame() {
  draw();
  if (step<360) {
    requestAnimFrame(onEnterFrame, ctx);
  } else {
    draw();
    callback();
  }
}
onEnterFrame();

module.exports = function(progress, c) {
  progress = Math.ceil(360 * progress);
  endAngle = progress;
  callback = c;
};

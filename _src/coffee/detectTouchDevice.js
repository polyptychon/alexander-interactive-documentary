module.exports = function is_touch_device() {
  return 'ontouchstart' in window // works on most browsers
    || 'onmsgesturechange' in window; // works on ie10
};

module.exports = {
  timeToMiliSeconds : (time)->
    t = time.split(":")
    if t.length == 3
      hours = parseInt(t[0]) * 3600000
      minutes = parseInt(t[1]) * 60000
      seconds = parseInt(t[2]) * 1000
    else if t.length == 2
      hours = 0
      minutes = parseInt(t[0]) * 60000
      seconds = parseInt(t[1]) * 1000
    else
      return parseInt(time) * 1000
    return hours + minutes + seconds

  miliSecondsToTime : (totalSec)->
    hours = parseInt(totalSec / 3600) % 24
    minutes = parseInt(totalSec / 60) % 60
    seconds = Math.ceil(totalSec % 60);
    if (seconds == 60)
      minutes += 1
      seconds = 0
    if (minutes == 60)
      hours += 1
      minutes = 0
    if hours > 0
      result = (if hours < 10 then "0" + hours else hours) + ":" + (if minutes < 10 then "0" + minutes else minutes) + ":" + (if seconds < 10 then "0" + seconds else seconds)
    else
      result = (if minutes < 10 then  "0" + minutes else minutes) + ":" + (if seconds < 10 then "0" + seconds else seconds)
    return result
  }

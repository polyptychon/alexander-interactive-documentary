singleton = require 'singleton'
class Chapters extends singleton
  LOCAL_STORAGE_CHAPTER: 'chapter'
  LOCAL_STORAGE_TIME: 'time'
  LOCAL_STORAGE_SHOW_SUBTITLES: 'subtitles'
  currentChapterPlaying: 0
  showSubtitles: false
  chapters:
    [
      {
        title: "THE AGE OF HEROES"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_QXRUeEE5bnBLRTg"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_aHZDWDVyal9tSm8"
        subtitle: "https://googledrive.com/host/0Bw8k9x-W_uS_TVRxZWtRSUxpa1U"
        parsedSubtitle: null
        isPlayedOnce: false
        relatedItems: []
      }
      {
        title: "THE CLASSICAL REVOLUTION"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_ZEpSaEstQjgzcVk"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_bkF5eVNqckNYeWM"
        subtitle: "https://googledrive.com/host/0Bw8k9x-W_uS_bnlGN1B1dy1VZlk"
        parsedSubtitle: null
        isPlayedOnce: false
        relatedItems: []
      }
      {
        title: "THE LONG SHADOW"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_WDBjM0huRnlaMUU"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_S1ZRUkZwSUFteGs"
        subtitle: "https://googledrive.com/host/0Bw8k9x-W_uS_ZEUwbHZPVWwzTWM"
        parsedSubtitle: null
        isPlayedOnce: false
        relatedItems: []
      }
    ]
  flattenArray: (videos)->
    array = videos.concat()
    for video in videos
      array = array.concat this.flattenArray(video.relatedItems) if video.relatedItems? && video.relatedItems.length>0
    return array
  getAllRelatedItems: ()->
    array = []
    for video in this.chapters
      array = array.concat this.flattenArray(video.relatedItems) if video.relatedItems? && video.relatedItems.length>0
    return array
  getAllVideos: ()->
    return this.flattenArray(this.chapters)

  setCurrentChapterPlaying: (value)->
    if (value>this.getTotalChapter() || value<0)
      this.currentChapterPlaying = 0
    else
      this.currentChapterPlaying = value
  getCurrentChapterPlaying: ()->
    return this.currentChapterPlaying
  getTotalChapter: ()->
    return this.chapters.length
  getCurrentChapterSource: ()->
    this.chapters[this.currentChapterPlaying].source
  getCurrentChapterTitle: ()->
    this.chapters[this.currentChapterPlaying].title
  getCurrentChapterSubtitleURL: ()->
    this.chapters[this.currentChapterPlaying].subtitle

  setCurrentChapterSubtitle: (value)->
    this.chapters[this.currentChapterPlaying].parsedSubtitle = value
  getCurrentChapterSubtitle: ()->
    this.chapters[this.currentChapterPlaying].parsedSubtitle

  getSubtitleURLFromSource: (src)->
    return video.subtitle for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src
  getSubtitleFromSource: (src)->
    return video.parsedSubtitle for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src
  setVideoIsPlayed: (src)->
    video.isPlayedOnce = true for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src

module.exports = Chapters.get()

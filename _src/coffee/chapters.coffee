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
      }
      {
        title: "THE CLASSICAL REVOLUTION"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_ZEpSaEstQjgzcVk"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_bkF5eVNqckNYeWM"
        subtitle: "https://googledrive.com/host/0Bw8k9x-W_uS_OTZna1ZGVzJhLVU"
        parsedSubtitle: null
      }
      {
        title: "THE LONG SHADOW"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_WDBjM0huRnlaMUU"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_S1ZRUkZwSUFteGs"
        subtitle: "https://googledrive.com/host/0Bw8k9x-W_uS_ZEUwbHZPVWwzTWM"
        parsedSubtitle: null
      }
    ]
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

module.exports = Chapters.get()

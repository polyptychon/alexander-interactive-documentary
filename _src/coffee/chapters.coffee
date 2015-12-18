singleton = require 'singleton'
class Chapters extends singleton
  LOCAL_STORAGE_CHAPTER: 'chapter'
  LOCAL_STORAGE_TIME: 'time'
  currentChapterPlaying: 0
  chapters:
    [
      {
        title: "THE AGE OF HEROES"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_QXRUeEE5bnBLRTg"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_aHZDWDVyal9tSm8"
      }
      {
        title: "THE CLASSICAL REVOLUTION"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_ZEpSaEstQjgzcVk"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_bkF5eVNqckNYeWM"
      }
      {
        title: "THE LONG SHADOW"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_WDBjM0huRnlaMUU"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_S1ZRUkZwSUFteGs"
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

module.exports = Chapters.get()

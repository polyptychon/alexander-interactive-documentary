singleton = require 'singleton'
class Chapters extends singleton
  currentChapterPlaying: 0
  chapters:
    [
      {
        title: "The Age of Heroes"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_QXRUeEE5bnBLRTg"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_aHZDWDVyal9tSm8"
      }
      {
        title: "The Classical Revolution"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_ZEpSaEstQjgzcVk"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_bkF5eVNqckNYeWM"
      }
      {
        title: "The Long Shadow"
        source:
          webm: "https://googledrive.com/host/0Bw8k9x-W_uS_WDBjM0huRnlaMUU"
          mp4: "https://googledrive.com/host/0Bw8k9x-W_uS_S1ZRUkZwSUFteGs"
      }
    ]
  getCurrentChapterSource: ()->
    this.chapters[this.currentChapterPlaying].source
  getCurrentChapterTitle: ()->
    this.chapters[this.currentChapterPlaying].title

module.exports = Chapters.get()

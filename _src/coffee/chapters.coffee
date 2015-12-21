singleton = require 'singleton'
chapterData = require "./chapterData.coffee"
class Chapters extends singleton
  LOCAL_STORAGE_CHAPTER: 'chapter'
  LOCAL_STORAGE_TIME: 'time'
  LOCAL_STORAGE_SHOW_SUBTITLES: 'subtitles'
  currentChapterPlaying: 0
  showSubtitles: false
  chapters: chapterData
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
  getCurrentChapterSourceByIndex: (value)->
    if isNaN(value) || value>this.chapters.length || value<0
      this.chapters[0].source
    else
      this.chapters[value].source
  getCurrentChapterRelatedItems: ()->
    this.chapters[this.currentChapterPlaying].relatedItems
  getCurrentChapterRelatedItemByIndex: (index)->
    this.chapters[this.currentChapterPlaying].relatedItems[index]
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

  getVideoFromSource: (src)->
    return video for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src

  setVideoIsPlayed: (src)->
    video.isPlayedOnce = true for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src

module.exports = Chapters.get()

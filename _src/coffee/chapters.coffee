singleton = require 'singleton'

class Chapters extends singleton
  LANG: 'en'
  LOCAL_STORAGE_CHAPTER: 'chapter'
  LOCAL_STORAGE_TIME: 'time'
  LOCAL_STORAGE_SHOW_SUBTITLES: 'subtitles'
  currentChapterPlaying: 0
  showSubtitles: false
  chapters: require "./chapterData.coffee"
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
    return this.flattenArray(this.chapters[this.LANG])

  setCurrentChapterPlaying: (value)->
    if (value>this.getTotalChapter() || value<0)
      this.currentChapterPlaying = 0
    else
      this.currentChapterPlaying = value
  getCurrentChapterPlaying: ()->
    return this.currentChapterPlaying
  getTotalChapter: ()->
    return this.chapters.length
  getChapters: ()->
    return this.chapters[this.LANG]
  getCurrentChapterSourceByIndex: (value)->
    if isNaN(value) || value>this.chapters[this.LANG].length || value<0
      this.getChapters()[0].source
    else
      this.getChapters()[value].source
  getCurrentChapterRelatedItems: ()->
    this.getChapters()[this.currentChapterPlaying].relatedItems
  getCurrentChapterRelatedItemByIndex: (index)->
    this.getChapters()[this.currentChapterPlaying].relatedItems[index]
  getCurrentChapterSource: ()->
    this.getChapters()[this.currentChapterPlaying].source
  getCurrentChapterTitle: ()->
    this.getChapters()[this.currentChapterPlaying].title
  getCurrentChapterSubtitleURL: ()->
    this.getChapters()[this.currentChapterPlaying].subtitle

  setCurrentChapterSubtitle: (value)->
    this.getChapters()[this.currentChapterPlaying].parsedSubtitle = value
  getCurrentChapterSubtitle: ()->
    this.getChapters()[this.currentChapterPlaying].parsedSubtitle

  getVideoFromSource: (src)->
    return video for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src

  setVideoIsPlayed: (src)->
    video.isPlayedOnce = true for video in this.getAllVideos() when video.source.webm==src || video.source.mp4==src

module.exports = Chapters.get()

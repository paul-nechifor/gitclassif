crypto = require 'crypto'
fs = require 'fs'
mkdirp = require 'mkdirp'
path = require 'path'
request = require 'request'
scraper = require 'scraper'
tmp = require 'tmp'

module.exports = class Scraper
  constructor: (scraperSource) ->
    @saveDir = makeSaveDir scraperSource
    @urls = []

  scrape: (url, cb) ->
    scraper url, cb
  
  start: (cb) ->
    next = =>
      return cb() if @urls.length is 0
      url = @urls.pop()
      console.log 'Getting', url
      @scrapeUrl url, (err, list) =>
        return cb err if err
        @saveImages list, (err) ->
          # Ignore error so far.
          next()
    next()

  scrapeUrl: (url, cb) ->
    throw 'Not implemented.'

  saveImages: (list, cb) ->
    i = 0
    next = =>
      return cb() if i >= list.length
      @saveImage list[i], (err) ->
        return cb err if err
        i++
        next()
    next()

  saveImage: (item, cb) ->
    tmp.tmpName {dir: '.'}, (err, path) =>
      return cb err if err
      @getImage item.imgSrc, path, (err, isGood) =>
        return cb err if err
        return cb null if not isGood
        getFileSha path, (err, hash) =>
          console.log '-', hash
          @moveImage path, hash, item, ->
            cb()

  getImage: (url, filename, cb) ->
    request.head url, (err, res, body) ->
      return cb err if err
      return cb null, false unless res.headers['content-type'] is 'image/gif'
      request(url).pipe(fs.createWriteStream(filename)).on 'close', ->
        cb null, true

  moveImage: (path, hash, item, cb) ->
    newPath = "#{@saveDir}/#{hash}.gif"
    json = "#{@saveDir}/#{hash}.json"
    fs.renameSync path, newPath
    fs.writeFileSync json, JSON.stringify item
    cb()
    
makeSaveDir = (filename) ->
  name = path.basename filename, path.extname filename
  path = __dirname + '/../gifs/' + name
  mkdirp.sync path
  path
  
getFileSha = (path, cb) ->
  hash = crypto.createHash 'sha1'
  s = fs.ReadStream(path)
  s.on 'data', (data) -> hash.update data
  s.on 'end', ->
    cb null, hash.digest 'hex'

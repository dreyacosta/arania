request = require 'request'
cheerio = require 'cheerio'
Cron    = require('cron').CronJob

class Crawl
  urls_queue: []

  scraped_urls: []

  working: false

  constructor: (config = {}) ->
    @requestsToStopper = config.requestsToStopper or 50
    @stopperTimeout = config.stopperTimeout or 60000
    @cron = new Cron
      cronTime: config.cronTime or '* * * * * *'
      onTick: @start
      start: true
      timeZone: config.timeZone or 'Europe/Madrid'
      context: @

  start: (urls = []) ->
    console.log "Start URLs: #{urls}"
    unless @working
      @urls_queue = urls
      @scraped_urls = []
      @threads = 0
      @requestsFromLastStopper = 0
      @working = true
      do @scrape

  finish: ->
    console.log "Finish"
    @working = false

  stopper: ->
    unless @timeoutId
      console.log "Waiting #{@stopperTimeout}... Scraped URLs: #{@scraped_urls.length}"
      @timeoutId = setTimeout =>
        delete @timeoutId
        @requestsFromLastStopper = 0
        do @scrape
      , @stopperTimeout

  scrape: ->
    if @requestsFromLastStopper < @requestsToStopper
      url = @urls_queue.shift()
      while url
        @makeRequest url
        @scraped_urls.push url
        @threads++
        @requestsFromLastStopper++
        url = @urls_queue.shift()
      if @threads is 0 then do @finish
    else
      do @stopper

  makeRequest: (url) ->
    data =
      url: url
      encoding: 'utf8'
    request data, do @preprocessResponse
    console.log "Scraping... #{url}"

  preprocessResponse: ->
    (error, response, body) =>
      if not error and response.statusCode is 200
        @parseResponse error, response, cheerio(body)
      @threads--
      do @scrape

module.exports = Crawl
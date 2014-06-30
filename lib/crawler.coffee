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

  start: (urls = [], callback) ->
    console.log "Start URLs: #{urls}"
    unless @working
      @data_queue = []
      @urls_queue = []
      @scraped_urls = []
      @threads = 0
      @requestsFromLastStopper = 0
      @queue url, callback for url in urls
      @working = true
      do @scrape

  finish: ->
    console.log "Finish"
    @working = false

  stopper: ->
    unless @timeoutId
      @timeoutId = setTimeout =>
        delete @timeoutId
        @requestsFromLastStopper = 0
        do @scrape
      , @stopperTimeout

  queue: (url, callback) ->
    if @urls_queue.indexOf(url) is -1 and @scraped_urls.indexOf(url) is -1
      @data_queue[url] = url: url, callback: callback
      @urls_queue.push url

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
      console.log "Waiting #{@stopperTimeout}ms Scraped: #{@scraped_urls.length}"
      console.log "Threads: #{@threads}"
      console.log "Queue: #{@urls_queue.length}"

  makeRequest: (url) ->
    data =
      url: url
      encoding: 'utf8'
    request data, @preprocessResponse url
    console.log "Scraping... #{url}"

  preprocessResponse: (url) ->
    (error, response, body) =>
      if not error and response.statusCode is 200
        @data_queue[url].callback.call @, error, response, cheerio(body)
      @threads--
      do @scrape

module.exports = Crawl
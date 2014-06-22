request = require 'request'
cheerio = require 'cheerio'
Cron    = require('cron').CronJob

class Crawl
  urls_queue: []

  scraped_urls: []

  working: false

  constructor: (config = {}) ->
    @requestsToTimeout = config.requestsToTimeout or 50
    @stopperTimeout = config.stopperTimeout or 60000
    @cron = new Cron
      cronTime: config.cronTime or '* * * * * *'
      onTick: @start
      start: true
      timeZone: config.timeZone or 'Europe/Madrid'
      context: @

  start: (urls = []) ->
    console.log 'start', urls
    unless @working
      @urls_queue = urls
      @scraped_urls = []
      @threads = 0
      @requestsFromLastTimeout = 0
      @working = true
      do @scrape

  finish: ->
    console.log 'Finish'
    @working = false

  scrape: ->
    url = @urls_queue.shift()
    while url
      @makeRequest url
      @scraped_urls.push url
      @threads++
      @requestsFromLastTimeout++
      console.log 'Time 2', @requestsFromLastTimeout, @requestsToTimeout
      url = @urls_queue.shift()
    if @threads is 0 then do @finish

  makeRequest: (url) ->
    request url, do @preprocessResponse
    # console.log 'Scraping', url

  preprocessResponse: ->
    (error, response, body) =>
      if not error and response.statusCode is 200
        @parseResponse error, response, cheerio(body)
      @threads--
      do @scrape

module.exports = Crawl
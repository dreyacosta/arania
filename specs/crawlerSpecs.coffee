expect  = require('chai').expect
Crawler = require '../lib/crawler.coffee'

class MyCrawl extends Crawler
  results: []
  resultsThings: []

  start: ->
    urls = []

    urls.push 'http://www.reddit.com/r/javascript'
    super urls, @item

  item: (error, response, body) ->
    titles = body.find('.thing > .entry > .title > a')
    titles.each (i, el) =>
      data =
        href: titles.eq(i).attr('href')
        title: titles.eq(i).html()
      domain = 'http://reddit.com'
      regexQuery = new RegExp 'http.*'
      data.href = "#{domain}#{data.href}" unless data.href.match regexQuery
      @queue data.href, @thingParser
    @results.push body

  thingParser: (error, response, body) ->
    do @finish if @resultsThings.length is 25
    @resultsThings.push body

myCrawl = new MyCrawl
  cronTime: '00 00 00 29 2 *'
  requestsToStopper: 100

describe 'Arania crawler', ->
  it 'should crawl 2 results and 25 resultsThings', (done) ->
    this.timeout 10000
    do myCrawl.start
    setTimeout ->
      expect(myCrawl.results.length).to.equal 1
      expect(myCrawl.resultsThings.length).to.equal 25
      do myCrawl.cron.finish
      do done
    , 5000
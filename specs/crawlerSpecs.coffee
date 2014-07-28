expect  = require('chai').expect
Crawler = require '../lib/crawler.coffee'

class MyCrawl extends Crawler
  results: []

  start: ->
    @parseResponse = @item
    urls = []
    urls.push 'http://www.reddit.com/r/css'
    urls.push 'http://www.reddit.com/r/javascript'
    super urls, @item

  item: (error, response, body) ->
    @results.push body

myCrawl = new MyCrawl
  cronTime: '00 00 00 29 2 *'
  requestsToStopper: 100

describe 'Arania crawler', ->
  it 'should crawl 2 URLs', (done) ->
    this.timeout 10000
    do myCrawl.start
    setTimeout ->
      expect(myCrawl.results.length).to.equal(2)
      do myCrawl.cron.stop
      do done
    , 5000
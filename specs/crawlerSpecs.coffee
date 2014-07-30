expect  = require('chai').expect
Crawler = require '../lib/crawler.coffee'

class MyCrawl extends Crawler
  redditPageResults: []
  thingPageResults: []

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
    @redditPageResults.push body

  thingParser: (error, response, body) ->
    @thingPageResults.push body unless @thingPageResults.length is 25

myCrawl = new MyCrawl
  cronTime: '00 00 00 29 2 *'
  requestsToStopper: 100

describe 'Arania crawler', ->
  it 'should parse 1 redditPageResults and 25 thingPageResults', (done) ->
    this.timeout 10000
    do myCrawl.start
    setTimeout ->
      expect(myCrawl.redditPageResults.length).to.equal 1
      expect(myCrawl.thingPageResults.length).to.equal 25
      do myCrawl.cron.stop
      do done
    , 5000
expect  = require('chai').expect
Crawler = require '../lib/crawler.coffee'

class MyCrawl extends Crawler
  constructor: ->
    super
    @redditPageResults = []
    @thingPageResults = []
    @runningTimes = 0

  start: ->
    @runningTimes++
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


describe 'Arania crawler', ->
  after ->
    process.exit 0

  it 'should parse 1 redditPageResults and 25 thingPageResults', (done) ->
    this.timeout 30000

    myCrawl = new MyCrawl
      cronTime: '00 00 * * * *'

    do myCrawl.start
    setTimeout ->
      expect(myCrawl.redditPageResults.length).to.equal 1
      expect(myCrawl.thingPageResults.length).to.equal 25
      do myCrawl.cron.stop
      do done
    , 5000

  it 'should be run 3 times via CronJob', (done) ->
    this.timeout 60000

    myCrawl = new MyCrawl
      cronTime: '*/10 * * * * *'
      requestsToStopper: 100

    setTimeout ->
      expect(myCrawl.runningTimes).to.equal 3
      do myCrawl.cron.stop
      do done
    , 29000

  it 'should stop after 5 requests', (done) ->
    this.timeout 30000

    myCrawl = new MyCrawl
      cronTime: '00 00 * * * *'
      requestsToStopper: 5

    do myCrawl.start
    setTimeout ->
      expect(myCrawl.redditPageResults.length).to.equal 1
      expect(myCrawl.thingPageResults.length).to.equal 5
      do myCrawl.finish
      do myCrawl.cron.stop
      do done
    , 10000
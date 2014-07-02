Crawl = require './lib/crawler.coffee'

web = 'http://www.reddit.com/r/coffeescript'

class MyCrawler extends Crawl
  results: []

  start: ->
    urls = []
    urls.push web
    super urls, @itemParser

  itemParser: (error, response, body) ->
    navigation = body.find('.nextprev > a')
    navigation.each (i, el) =>
      url = navigation.eq(i).attr('href')
      @queue url, @itemParser

    titles = body.find('.thing > .entry > .title > a')
    titles.each (i, el) =>
      data =
        href: titles.eq(i).attr('href')
        title: titles.eq(i).html()
      @queue data.href, @questionPageParser

  questionPageParser: (error, response, body) ->

crawl = new MyCrawler
  cronTime: '00 43 * * * *'
  requestsToStopper: 100
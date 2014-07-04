Crawl = require '../lib/crawler.coffee'

web = 'http://www.reddit.com/r/coffeescript'

class MyCrawler extends Crawl
  resultsItemParser: []
  resultsPageParser: []

  start: ->
    urls = []
    urls.push web
    super urls, @itemParser

  finish: ->
    console.log 'resultsItemParser:', @resultsItemParser
    console.log 'resultsPageParser:', @resultsPageParser
    super

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
      @resultsItemParser.push data
      @queue data.href, @questionPageParser

  questionPageParser: (error, response, body) ->
    pageTitle = body.find('html > head > title').html()
    @resultsPageParser.push pageTitle
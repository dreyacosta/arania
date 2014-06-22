# Arania
Node.js screen scraping and web crawling module

## Installation
```shell
$ npm install arania
```

## Usage
### Extends crawler 'Class'
First of all you have to require `arania` and extends the class with two
mandatory methods. Also you could export your extension as a module:

```coffeescript
'use strict'

Crawler = require 'arania'

web = 'http://www.reddit.com/r/coffeescript'

class MyCrawler extends Crawler
  results: []

  start:
    urls = []
    urls.push web
    @parseResponse = @itemParser
    super urls # Urls must be passed to super

  itemParser: (error, response, body) ->
    navigation = body.find('.nextprev > a')
    navigation.each (i, el) =>
      url = navigation.eq(i).attr('href')
      # You can add more URLs to scrappe
      @urls_queue.push url

    titles = body.find('.thing > .entry > .title > a')
    titles.each (i, el) =>
      data =
        href: titles.eq(i).attr('href')
        title: titles.eq(i).html()
      @results.push data

module.exports = MyCrawler
```
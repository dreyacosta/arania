# Arania [![Build Status](https://travis-ci.org/dreyacosta/arania.svg?branch=master)](https://travis-ci.org/dreyacosta/arania)
> Node.js screen scraping and web crawling module heavily inspired
by [Yoi](https://github.com/tapquo/yoi) project.

## Installation
```bash
$ npm install arania --save
```

## Usage
### Extends crawler 'Class'
First of all you have to require `arania` and extends the class with two
mandatory methods. Also you could export your extension as a module.

[See one example](https://github.com/dreyacosta/arania/blob/master/examples/reddit.coffee)

### Use your crawler
Now you can import your crawler and pass some configurations:

```coffeescript
'use strict'

RedditCrawler = require './examples/reddit.coffee'

# Options that you can pass to your crawler:
#   - cronTime: schedule crawler to run periodically
#   - requestsToStopper: timeout your crawler every X requests
#   - stopperTimeout: milliseconds for the crawler stopper
redditCrawler = new RedditCrawler
  cronTime: '00 38 * * * *'
  requestsToStopper: 100
  stopperTimeout: 30000
```

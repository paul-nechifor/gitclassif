Scraper = require '../src/Scraper'

site = 'http://securityreactions.tumblr.com'

class DevopsScraper extends Scraper
  scrapeUrl: (url, cb) ->
    @scrape url, (err, $) =>
      return cb err if err
      list = @extractData $
      nextUrl = $('#footer .next').attr 'href'
      if nextUrl
        @urls.push site + nextUrl
      cb null, list

  extractData: ($) ->
    list = []
    $('.post').each ->
      item = $ this
      title = item.find('.regular h2').text().trim()
      item.find('p img').each ->
        list.push
          title: title
          imgSrc: $(this).attr 'src'
    list

main = ->
  scraper = new DevopsScraper __filename
  scraper.urls.push site
  scraper.start()

main()

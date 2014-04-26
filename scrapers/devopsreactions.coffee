Scraper = require '../src/Scraper'

site = 'http://devopsreactions.tumblr.com'

class DevopsScraper extends Scraper
  scrapeUrl: (url, cb) ->
    @scrape url, (err, $) =>
      return cb err if err
      list = @extractData $
      nextUrl = $('#older_posts').attr 'href'
      if nextUrl
        @urls.push site + nextUrl
      cb null, list

  extractData: ($) ->
    list = []
    $('.item_content').each ->
      item = $ this
      title = item.find('.post_title a').text().trim()
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

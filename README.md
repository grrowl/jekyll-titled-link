# Titled Tag plugin for Jekyll

This plugin enables a Liquid tag which will automatically create links using the source location's title attribute. For example, a link to `https://github.com/` will display the text "GitHub · Where software is built".

Title detection is [(very) rudimentary](http://stackoverflow.com/a/1732454/894361), mostly to avoid a heavy requirement like nokogiri. If you come across a page title in the wild which doesn't work, please file an issue

# How To Install

  1. Copy `titled_link.rb` into `<your-jekyll-project>/_plugins` or `<your-ocotpress-project>/plugins`.
  2. That is all.

# How To use

Place a `titled_link` tag in your content file, along with the URL, e.g.:
```
{% titled_link https://github.com %}
```

The first argument to the `tweet` tag must be the tweet URL, but everything after that is optional. You can pass
any parameter supported by the [Twitter oEmbed API](https://dev.twitter.com/docs/api/1/get/statuses/oembed) in the form
`key='value'`.

# Caching

To avoid downloading every linked page on rebuild, we cache the titles in a directory named `.link-cache`. It will never update after the initial check, but you can safely delete `.link-cache` to recreate it on next load, and refresh all link titles.

You can also use the `titled_linknocache` tag to bypasses the cache. This is not recommended since it will download every link on a page when it is regenerated.

# Author

Tom McKenzie -- http://chillidonut.com

# Credits

This code is adapted from [Tweet Tag](https://github.com/scottwb/jekyll-tweet-tag), which itself is inspired by the [Gist Tag](https://gist.github.com/1027674) plugin by Brandon Tilley and the
[oEmbed Tag](https://gist.github.com/1455726) by Tammo van Lessen.

# License

This code is licensed under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)

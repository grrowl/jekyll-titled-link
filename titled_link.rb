# Embeds links with their source document titles.
#
# Adapted from Tweet Tag:
#   Author: Scott W. Bradley
#   Source URL: https://github.com/scottwb/jekyll-tweet-tag
#
# Example usage:
#   {% titled_link https://www.theguardian.com/ %}
#
# Documentation:
#   https://github.com/grrowl/jekyll-titled-link/blob/master/README.md
#

require 'json'
require 'net/http'

module Jekyll
  class TitledTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text           = text
      @cache_disabled = false
      @cache_folder   = File.expand_path "../.link-cache", File.dirname(__FILE__)
      FileUtils.mkdir_p @cache_folder
    end

    def render(context)
      uri = context[@text] || @text

      title = cached_response(uri) || live_response(uri) || uri
      title = uri if title == ""

      "<a href=\"#{uri}\" target=\"_blank\">#{title}</a>"
    end

    def cache(uri, data)
      cache_file = cache_file_for(uri)
      File.open(cache_file, "w:UTF-8") do |f|
        f.write({
          uri: uri,
          data: data
        }.to_json)
      end
    end

    def cached_response(uri)
      return nil if @cache_disabled
      cache_file = cache_file_for(uri)
      JSON.parse(File.read(cache_file))['data'] if File.exist?(cache_file)
    end

    def cache_file_for(uri)
      filename = "#{Base64.urlsafe_encode64(uri)}.cache"
      File.join(@cache_folder, filename)
    end

    def get_title_from(html)
      title_tag = /<title>(.+?)<\/title>/.match(html)

      return (title_tag && title_tag[1]) || ""
    end

    def live_response(uri)
      uri = URI(uri)
      response = nil
      puts "Fetching title of %s"% uri

      begin
        Net::HTTP.start(uri.host, uri.port,
          :continue_timeout => 3,
          :read_timeout => 3,
          :use_ssl => uri.scheme == 'https'
          ) do |http|
          request = Net::HTTP::Get.new uri.request_uri

          response = http.request request # Net::HTTPResponse object
        end
      rescue TimeoutError
        puts "! Timeout fetching %s"% uri.host
      rescue
        puts "! Error fetching %s: %s"% [uri.host, $!, $!.class]
      end

      return unless response.class <= Net::HTTPSuccess

      title = get_title_from(response.body).force_encoding("UTF-8")
      cache(uri.to_s, title) unless @cache_disabled
      title
    end
  end

  class TitledTagNoCache < TitledTag
    def initialize(tag_name, text, token)
      super
      @cache_disabled = true
    end
  end
end

Liquid::Template.register_tag('titled_link', Jekyll::TitledTag)
Liquid::Template.register_tag('titled_linknocache', Jekyll::TitledTagNoCache)

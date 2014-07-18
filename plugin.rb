# name: Discourse YouTube Lite Embed
# about: Uses the YouTube Lite Embed plugin embed fast light-weight YouTube videos
# version: 0.1
# authors: Arpit Jalan


register_asset "javascripts/vendor/jquery.lazyload.js"
register_asset "javascripts/vendor/lite-youtube.js"

register_asset "stylesheets/discourse-youtube-lite-embed.scss"

# First, load the Engine stuff
Onebox::Engine
Onebox::Engine::YoutubeOnebox

# Now, remove it.
Onebox::Engine::WhitelistedGenericOnebox.whitelist.delete "youtube.com"
[:YoutubeOnebox, :YouTubeOnebox].each do |engine|
    begin
        Onebox::Engine::send(:remove_const, engine)
    rescue
    end
end

class Onebox::Engine::YoutubeOnebox
  include Onebox::Engine


  matches_regexp(/^https?:\/\/(?:www\.)?(?:m\.)?(?:youtube\.com|youtu\.be)\/.+$/)

      # Try to get the video ID. Works for URLs of the form:
      # * https://www.youtube.com/watch?v=Z0UISCEe52Y
      # * http://youtu.be/afyK1HSFfgw
      # * https://www.youtube.com/embed/vsF0K3Ou1v0
      def video_id
        match = @url.match(/^https?:\/\/(?:www\.)?(?:m\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_\-]{11})(?:\?.*)?$/)
        match && match[1]
      end

      def placeholder_html
        if video_id
          "<img src='http://i1.ytimg.com/vi/#{video_id}/hqdefault.jpg' width='480' height='270'>"
        else
          to_html
        end
      end

      def to_html
        if video_id
          # Avoid making HTTP requests if we are able to get the video ID from the
          # URL.
          # html = "<iframe width=\"480\" height=\"270\" src=\"https://www.youtube.com/embed/#{video_id}?feature=oembed\" frameborder=\"0\" allowfullscreen></iframe>"
          html = "<div class=\"lite\" id=\"#{video_id}\" style=\"width:640px;height:360px;\"></div>"
        else
          # Fall back to making HTTP requests.
          html = raw[:html] || ""
        end

        rewrite_agnostic(append_params(html))
      end

      def append_params(html)
        result = html.dup
        result.gsub! /(src="[^"]+)/, '\1&wmode=opaque'
        if url =~ /t=(\d+h)?(\d+m)?(\d+s?)?/
          h = Regexp.last_match[1].to_i
          m = Regexp.last_match[2].to_i
          s = Regexp.last_match[3].to_i

          total = (h * 60 * 60) + (m * 60) + s

          result.gsub! /(src="[^"]+)/, '\1&start=' + total.to_s
        end
        result
      end

      def rewrite_agnostic(html)
        html.gsub(/https?:\/\//, '//')
      end

end

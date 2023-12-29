require 'json'
require 'net/http'
require 'uri'

module Copilot2gpt

  class Token
    attr_accessor :token, :expires_at

    CACHE = {}

    def initialize(token, expires_at)
      @token = token
      @expires_at = expires_at
    end

    class << self
      def get_token_from_cache(github_token)
        extra_time = rand(600) + 300
        if CACHE.key?(github_token) && CACHE[github_token].expires_at > Time.now.to_i + extra_time
          return CACHE[github_token]
        end
        Token.new("", 0)
      end

      def get_copilot_token(github_token)
        token = get_token_from_cache(github_token)
        if token.token.empty?
          get_token_url = "https://api.github.com/copilot_internal/v2/token"
          uri = URI(get_token_url)
          req = Net::HTTP::Get.new(uri)
          req['Authorization'] = "token #{github_token}"
          res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
            http.request(req)
          }
          if res.code != "200"
            raise "Failed to get copilot token: #{res.code} #{res.body}"
          end
          copilot_token = JSON.parse(res.body, object_class: OpenStruct)
          token.token = copilot_token.token
          CACHE[github_token] = Token.new(copilot_token.token, copilot_token.expires_at)
        end
        token.token
      end
    end
  end

end
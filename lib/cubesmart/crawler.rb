# frozen_string_literal: true

module CubeSmart
  # Used to fetch and parse either HTML or XML via a URL.
  class Crawler
    HOST = 'https://www.cubesmart.com'

    # Raised for unexpected HTTP responses.
    class FetchError < StandardError
      # @param url [String]
      # @param response [HTTP::Response]
      def initialize(url:, response:)
        super("url=#{url} status=#{response.status.inspect} body=#{String(response.body).inspect}")
      end
    end

    # @param url [String]
    # @raise [FetchError]
    # @return [Nokogiri::HTML::Document]
    def self.html(url:)
      new.html(url:)
    end

    # @param url [String]
    # @raise [FetchError]
    # @return [Nokogiri::XML::Document]
    def self.xml(url:)
      new.xml(url:)
    end

    # @return [HTTP::Client]
    def connection
      @connection ||= begin
        config = CubeSmart.config

        connection = HTTP.persistent(HOST)
        connection = connection.headers('User-Agent' => config.user_agent) if config.user_agent
        connection = connection.timeout(config.timeout) if config.timeout
        connection
      end
    end

    # @param url [String]
    # @return [HTTP::Response]
    def fetch(url:)
      response = connection.get(url)
      raise FetchError.new(url:, response: response.flush) unless response.status.ok?

      response
    end

    # @param url [String]
    # @raise [FetchError]
    # @return [Nokogiri::XML::Document]
    def html(url:)
      Nokogiri::HTML(String(fetch(url:).body))
    end

    # @param url [String]
    # @raise [FetchError]
    # @return [Nokogiri::XML::Document]
    def xml(url:)
      Nokogiri::XML(String(fetch(url:).body))
    end
  end
end

# frozen_string_literal: true

module CubeSmart
  # The core configuration.
  class Config
    # @attribute [rw] user_agent
    #   @return [String]
    attr_accessor :user_agent

    # @attribute [rw] timeout
    #   @return [Integer]
    attr_accessor :timeout

    # @attribute [rw] proxy_url
    #   @return [String]
    attr_accessor :proxy_url

    def initialize
      @user_agent = ENV.fetch('CUBESMART_USER_AGENT', "cubesmart.rb/#{VERSION}")
      @timeout = Integer(ENV.fetch('CUBESMART_TIMEOUT', 60))
      @proxy_url = ENV.fetch('CUBESMART_PROXY_URL', nil)
    end

    # @return [Boolean]
    def proxy?
      !@proxy_url.nil?
    end

    # @return [URI]
    def proxy_uri
      @proxy_uri ||= URI.parse(proxy_url) if proxy?
    end

    # @return [Integer]
    def proxy_port
      proxy_uri&.port
    end

    def proxy_host
      proxy_uri&.host
    end

    # @return [String]
    def proxy_scheme
      proxy_uri&.scheme
    end

    # @return [String]
    def proxy_username
      proxy_uri&.user
    end

    # @return [String]
    def proxy_password
      proxy_uri&.password
    end

    # @return [Array]
    def proxy_options
      [proxy_host, proxy_port, proxy_username, proxy_password]
    end
  end
end

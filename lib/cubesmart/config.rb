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

    def initialize
      @user_agent = ENV.fetch('CUBESMART_USER_AGENT', "cubesmart.rb/#{VERSION}")
      @timeout = Integer(ENV.fetch('CUBESMART_TIMEOUT', 60))
    end
  end
end

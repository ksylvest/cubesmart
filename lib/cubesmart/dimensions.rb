# frozen_string_literal: true

module CubeSmart
  # The dimensions (width + depth + sqft) of a price.
  class Dimensions
    # @attribute [rw] depth
    #   @return [Integer]
    attr_accessor :depth

    # @attribute [rw] width
    #  @return [Integer]
    attr_accessor :width

    # @attribute [rw] sqft
    #   @return [Integer]
    attr_accessor :sqft

    # @param depth [Integer]
    # @param width [Integer]
    # @param sqft [Integer]
    def initialize(depth:, width:, sqft:)
      @depth = depth
      @width = width
      @sqft = sqft
    end

    # @return [String]
    def inspect
      props = [
        "depth=#{@depth.inspect}",
        "width=#{@width.inspect}",
        "sqft=#{@sqft.inspect}"
      ]
      "#<#{self.class.name} #{props.join(' ')}>"
    end

    # @return [String] e.g. "10' × 10' (100 sqft)"
    def text
      "#{format('%g', @width)}' × #{format('%g', @depth)}' (#{@sqft} sqft)"
    end

    # @param element [Nokogiri::XML::Element]
    #
    # @return [Dimensions]
    def self.parse(element:)
      text = element.text
      match = text.match(/(?<width>[\d\.]+)'x(?<depth>[\d\.]+)'/)
      raise text.inspect if match.nil?

      width = Float(match[:width])
      depth = Float(match[:depth])
      sqft = Integer(width * depth)
      new(depth:, width:, sqft:)
    end
  end
end

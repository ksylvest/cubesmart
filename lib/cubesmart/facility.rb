# frozen_string_literal: true

module CubeSmart
  # A facility (address + geocode + prices) on cubesmart.com.
  #
  # e.g. https://www.cubesmart.com/arizona-self-storage/chandler-self-storage/2.html
  class Facility
    class ParseError < StandardError; end

    SITEMAP_URL = 'https://www.cubesmart.com/sitemap-facility.xml'

    PRICE_SELECTOR = %w[small medium large].map do |group|
      ".#{group}-group ul.csStorageSizeDimension li.csStorageSizeDimension"
    end.join(', ')

    ID_REGEX = /(?<id>\d+)\.html/

    # @attribute [rw] id
    #   @return [String]
    attr_accessor :id

    # @attribute [rw] name
    #   @return [String]
    attr_accessor :name

    # @attribute [rw] address
    #   @return [Address]
    attr_accessor :address

    # @attribute [rw] geocode
    #   @return [Geocode]
    attr_accessor :geocode

    # @attribute [rw] prices
    #   @return [Array<Price>]
    attr_accessor :prices

    # @return [Sitemap]
    def self.sitemap
      Sitemap.fetch(url: SITEMAP_URL)
    end

    # @param url [String]
    #
    # @return [Facility]
    def self.fetch(url:)
      document = Crawler.html(url:)
      parse(document:)
    end

    # @param document [Nokogiri::HTML::Document]
    #
    # @return [Facility]
    def self.parse(document:)
      data = parse_json_ld(document:)

      id = data['url'].match(ID_REGEX)[:id]
      name = data['name']
      address = Address.parse(data: data['address'])
      geocode = Geocode.parse(data: data['geo'])
      prices = document.css(PRICE_SELECTOR).map { |element| Price.parse(element: element) }

      new(id:, name:, address:, geocode:, prices:)
    end

    # @param document [Nokogiri::HTML::Document]
    #
    # @raise [ParseError]
    #
    # @return [Hash]
    def self.parse_json_ld(document:)
      graph = JSON.parse(document.at_xpath('//script[contains(text(), "@graph")]').text)['@graph']
      graph.find { |entry| entry['@type'] == 'SelfStorage' } || raise(ParseError, 'missing @graph')
    end

    # @param id [String]
    # @param name [String]
    # @param address [Address]
    # @param geocode [Geocode]
    # @param prices [Array<Price>]
    def initialize(id:, name:, address:, geocode:, prices:)
      @id = id
      @name = name
      @address = address
      @geocode = geocode
      @prices = prices
    end

    # @return [String]
    def inspect
      props = [
        "id=#{@id.inspect}",
        "address=#{@address.inspect}",
        "geocode=#{@geocode.inspect}",
        "prices=#{@prices.inspect}"
      ]
      "#<#{self.class.name} #{props.join(' ')}>"
    end

    # @return [String]
    def text
      "#{@id} | #{@name} | #{@address.text} | #{@geocode.text}"
    end
  end
end

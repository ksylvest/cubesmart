# frozen_string_literal: true

module CubeSmart
  # A facility (address + geocode + prices) on cubesmart.com.
  #
  # e.g. https://www.cubesmart.com/arizona-self-storage/chandler-self-storage/2.html
  class Facility
    class ParseError < StandardError; end

    DEFAULT_EMAIL = 'webleads@cubesmart.com'
    DEFAULT_PHONE = '1-877-279-7585'

    SITEMAP_URL = 'https://www.cubesmart.com/sitemap-facility.xml'

    PRICE_SELECTOR = %w[small medium large].map do |group|
      ".#{group}-group ul.csStorageSizeDimension li.csStorageSizeDimension"
    end.join(', ')

    ID_REGEX = /(?<id>\d+)\.html/

    # @attribute [rw] id
    #   @return [String]
    attr_accessor :id

    # @attribute [rw] url
    #   @return [String]
    attr_accessor :url

    # @attribute [rw] name
    #   @return [String]
    attr_accessor :name

    # @attribute [rw] phone
    #   @return [String]
    attr_accessor :phone

    # @attribute [rw] email
    #   @return [String]
    attr_accessor :email

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
      parse(url:, document:)
    end

    # @param url [String]
    # @param document [Nokogiri::HTML::Document]
    #
    # @return [Facility]
    def self.parse(url:, document:)
      data = parse_json_ld(document:)

      id = ID_REGEX.match(url)[:id]
      name = data['name']
      address = Address.parse(data: data['address'])
      geocode = Geocode.parse(data: data['geo'])
      prices = document.css(PRICE_SELECTOR).map { |element| Price.parse(element: element) }

      new(id:, url:, name:, address:, geocode:, prices:)
    end

    # @param document [Nokogiri::HTML::Document]
    #
    # @raise [ParseError]
    #
    # @return [Hash]
    def self.parse_json_ld(document:)
      scripts = document.xpath('//script[contains(text(), "@graph")]')

      scripts.each do |script|
        graph = JSON.parse(script)['@graph']
        entry = graph.find { |entry| entry['@type'] == 'SelfStorage' }
        return entry if entry
      rescue JSON::ParseError
        next
      end

      raise(ParseError, 'missing @graph for @type of "SelfStorage"')
    end

    # @param id [String]
    # @param url [String]
    # @param name [String]
    # @param address [Address]
    # @param geocode [Geocode]
    # @param phone [String]
    # @param email [String]
    # @param prices [Array<Price>]
    def initialize(id:, url:, name:, address:, geocode:, phone: DEFAULT_PHONE, email: DEFAULT_EMAIL, prices: [])
      @id = id
      @url = url
      @name = name
      @address = address
      @geocode = geocode
      @phone = phone
      @email = email
      @prices = prices
    end

    # @return [String]
    def inspect
      props = [
        "id=#{@id.inspect}",
        "url=#{@url.inspect}",
        "address=#{@address.inspect}",
        "geocode=#{@geocode.inspect}",
        "phone=#{@phone.inspect}",
        "email=#{@email.inspect}",
        "prices=#{@prices.inspect}"
      ]
      "#<#{self.class.name} #{props.join(' ')}>"
    end

    # @return [String]
    def text
      "#{@id} | #{@name} | #{@phone} | #{@email} | #{@address.text} | #{@geocode.text}"
    end
  end
end

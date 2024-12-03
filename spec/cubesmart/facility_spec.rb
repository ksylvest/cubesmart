# frozen_string_literal: true

RSpec.describe CubeSmart::Facility do
  describe '.sitemap' do
    subject(:sitemap) { described_class.sitemap }

    around { |example| VCR.use_cassette('cubesmart/facility/sitemap', &example) }

    it 'fetches and parses the sitemap' do
      expect(sitemap).to be_a(CubeSmart::Sitemap)
      expect(sitemap.links).to all(be_a(CubeSmart::Link))
    end
  end

  describe '.fetch' do
    subject(:fetch) { described_class.fetch(url: url) }

    let(:url) { 'https://www.cubesmart.com/arizona-self-storage/chandler-self-storage/2.html' }

    around { |example| VCR.use_cassette('cubesmart/facility/fetch', &example) }

    it 'fetches and parses the facility' do
      expect(fetch).to be_a(described_class)
      expect(fetch.address).to be_a(CubeSmart::Address)
      expect(fetch.geocode).to be_a(CubeSmart::Geocode)
      expect(fetch.prices).to all(be_a(CubeSmart::Price))
    end
  end
end

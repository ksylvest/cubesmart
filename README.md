# CubeSmart

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ksylvest/cubesmart/blob/main/LICENSE)
[![RubyGems](https://img.shields.io/gem/v/cubesmart)](https://rubygems.org/gems/cubesmart)
[![GitHub](https://img.shields.io/badge/github-repo-blue.svg)](https://github.com/ksylvest/cubesmart)
[![Yard](https://img.shields.io/badge/docs-site-blue.svg)](https://cubesmart.ksylvest.com)
[![CircleCI](https://img.shields.io/circleci/build/github/ksylvest/cubesmart)](https://circleci.com/gh/ksylvest/cubesmart)

## Installation

```bash
gem install cubesmart
```

## Configuration

```ruby
require 'cubesmart'

CubeSmart.configure do |config|
  config.user_agent = '../..' # ENV['CUBESMART_USER_AGENT']
  config.timeout = 30 # ENV['CUBESMART_TIMEOUT']
  config.proxy_url = 'http://user:pass@superproxy.zenrows.com:1337' # ENV['CUBESMART_PROXY_URL']
end
```

## Usage

```ruby
require 'cubesmart'

sitemap = CubeSmart::Facility.sitemap
sitemap.links.each do |link|
  url = link.loc
  facility = CubeSmart::Facility.fetch(url:)

  puts facility.text

  facility.prices.each do |price|
    puts price.text
  end

  puts
end
```

## CLI

```bash
cubesmart crawl
```

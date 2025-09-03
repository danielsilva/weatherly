source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "sqlite3", ">= 2.1"
gem "propshaft", "~> 1.2"
gem "puma", "~> 6.6"
gem "importmap-rails", "~> 2.2"
gem "turbo-rails", "~> 2.0"

gem "faraday", "~> 2.13"
gem "dotenv-rails", "~> 3.1"
gem "redis", "~> 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", "~> 1.18", require: false

group :development, :test do
  gem "debug", "~> 1.11", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails", "~> 6.4"
end

group :development do
  gem "web-console", "~> 4.2"
  gem "brakeman", "~> 7.1", require: false
  gem "rubocop-rails-omakase", "~> 1.1", require: false
end

group :test do
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.34"
  gem "webmock", "~> 3.24"
end

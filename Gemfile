# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 13.0"

group :development, :test do
  gem "rspec", require: false
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "shoulda-matchers", require: false
  gem "simplecov", require: false
  gem "webmock", require: false
end

group :development do
  gem "flay", require: false
  gem "flog", require: false
  gem "pry"
  gem "ruby-lsp", require: false
  gem "ruby-lsp-rspec", require: false
end

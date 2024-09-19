source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails"
# Use mysql as the database for Active Record
gem "mysql2"
# Use Puma as the app server
gem "puma"
# Use SCSS for stylesheets
gem "sass-rails"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker"

gem "hotwire-rails"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
gem "redis"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap"

# -- undefault gems --
gem "jquery-rails"

gem "devise"#, github: "heartcombo/devise"
gem "devise-encryptable"
gem "omniauth"
gem "omniauth-twitter"
gem "omniauth-facebook"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

gem "active_storage_validations"
gem "mini_magick"
gem "image_processing"
gem "commontator"
gem "will_paginate"

gem "sidekiq"

gem "searchkick"
gem "elasticsearch"

gem "chartkick"

gem "activeadmin"
gem "cancancan"
gem "draper"
gem "pundit"

gem "rack-attack"

gem "simple_form"
gem "noticed"
gem "mail_form"

gem "google-cloud-translate"
gem "deepl-rb", require: "deepl"
# japanese.to_hira, japanese.to_roman
gem "accept_language"
gem "kakasi"
gem "mojinizer"

gem "recaptcha"

gem "twitter"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  # gem 'rack-mini-profiler', '~> 2.0'
  gem "listen"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "rufo"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "capybara-email"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "faker"
  gem "database_cleaner-active_record"
  gem "rack-test"
  gem "rails-controller-testing"
  gem "rspec-sidekiq"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]



source 'https://rubygems.org'

gem 'rails', '~> 5.1.4'
gem 'puma', '~> 3.7'
gem 'bcrypt'
gem 'redis-rails'
gem 'line-bot-api'
gem 'api-ai-ruby'

gem 'bootstrap', '~> 4.0.0'
gem 'jquery-rails'

gem 'webpacker', github: 'rails/webpacker'
gem 'foreman'

gem 'capybara'
gem 'poltergeist', require: 'capybara/poltergeist'
gem 'holiday_jp'

gem 'uglifier', '>= 1.3.0'
# gem 'therubyracer', platforms: :ruby

group :production do
  gem 'pg', '0.18.4'
end

group :development, :test do
  gem 'sqlite3'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

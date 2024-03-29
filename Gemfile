# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'devise', '>= 4.8.1'
gem 'jbuilder', '~> 2.10', '>= 2.10.0'
gem 'jwt'
gem 'koala', '>= 3.0.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3', '>= 4.3.12'
gem 'pundit', '>= 2.1.0'
gem 'rack-cors'
gem 'rails', '~> 5.2.8', '>= 5.2.8.1'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'faker'
  gem 'hirb'
  gem 'pry-rails'
  gem 'rspec-rails', '>= 5.1.2'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'shoulda-matchers', '>= 4.3.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

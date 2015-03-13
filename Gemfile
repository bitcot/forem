source "https://rubygems.org"

gem 'forem-theme-base', :git => "git://github.com/radar/forem-theme-base", :branch => "master"

gemspec

gem 'pry-rails'
gem 'pry-nav'
gem 'select2-rails', '~> 3.5.4'

platforms :jruby do

end

platforms :ruby do
  gem 'bson_ext'
end

group :test do
  platforms :ruby, :mingw do
    gem "forem-redcarpet"
  end

  platforms :jruby do
    gem "forem-kramdown", :github => "phlipper/forem-kramdown", :branch => "master"
  end
end

if RUBY_VERSION < '1.9.2'
  gem 'nokogiri', '~> 1.5.9'
end

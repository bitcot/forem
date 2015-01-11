# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "rspec/rails"
require "capybara/rspec"
require 'fabrication'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), "../")
require 'database_cleaner'

# for some reason Fabrication is not auto-loading these
require File.expand_path("../fabricators/category_fabricator.rb",  __FILE__)
require File.expand_path("../fabricators/forum_fabricator.rb",  __FILE__)
require File.expand_path("../fabricators/post_fabricator.rb",  __FILE__)
require File.expand_path("../fabricators/topic_fabricator.rb",  __FILE__)
require File.expand_path("../fabricators/user_fabricator.rb",  __FILE__)
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

require 'forem/testing_support/factories'


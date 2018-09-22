ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
#require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
require 'bootsnap'
app_name = File.basename(File.expand_path("#{__dir__}/../"))
Bootsnap.setup(cache_dir: "/tmp/bootsnap/#{app_name}")

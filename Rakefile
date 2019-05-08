# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

module Vision
  VERSION = File.read('CHANGELOG.md')[/v([\d\.]+) /, 1]
end
desc "git ci, git tag and git push"
task :release do
  sh "git diff HEAD"
  v = "v#{Vision::VERSION}"
  puts "release as #{v}? [y/N]"
  break unless $stdin.gets.chomp == "y"

  sh "git ci -am '#{v}'"
  sh "git tag '#{v}'"
  sh "git push origin master --tags"
  sh "bundle exec cap production deploy"
end

source :rubygems
gemspec

require 'rbconfig'

case RbConfig::CONFIG['host_os']
when /darwin/
  gem 'rb-fsevent'
when /linux/
  gem 'rb-inotify'
end


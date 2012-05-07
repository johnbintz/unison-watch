module Unison
  class FilesystemWatcher
    class NoWatcherAvailable < StandardError ; end

    def initialize(paths, owner)
      @paths, @owner = paths, owner
    end

    def run
      require 'rbconfig'

      @watcher = Thread.new do
        while !Thread.current[:app]; sleep 0.1; end

        begin
          case RbConfig::CONFIG['host_os']
          when /(darwin|linux)/
            @watch = send("watcher_for_#{$1}")
          else
            raise NoWatcherAvailable.new
          end

          @watch.run
        rescue => e
          puts e.message
          puts e.backtrace.join("\n")
          exit
        end
      end

      @watcher[:paths] = @paths
      @watcher[:app] = @owner
    end

    def watcher_for_darwin
      require 'rb-fsevent'
      watch = FSEvent.new
      watch.watch Thread.current[:paths], :latency => 1.0 do |directories|
        Thread.current[:app] << directories
      end
      watch
    end

    def watcher_for_linux
      require 'rb-inotify'
      watch = INotify::Notifier.new
      Thread.current[:paths].each do |path|
        FileUtils.mkdir_p path

        watch.watch path, :recursive, :modify, :create, :delete do |event|
          Thread.current[:app] << event.absolute_name
        end
      end
      watch
    end
  end
end


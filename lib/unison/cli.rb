require 'thor'

module Unison
  class CLI < Thor
    include Thor::Actions

    desc 'start profile <profile> ...', 'Run Unison Watch using the provided profiles'
    def start(*profiles)
      Watcher.new(profiles, ARGV).start
    end

    default_task :run
    def method_missing(*args)
      start(*args)
    end

    def self.source_root
      File.join(Unison.root, 'skel')
    end

    desc 'app-bundle', 'Make an app bundle in the current directory'
    def app_bundle
      destination_path = Dir.pwd

      directory 'UnisonWatch.app', 'UnisonWatch.app'
      Dir['UnisonWatch.app/**/*'].each do |file|
        if File.directory?(file)
          File.chmod(0755, file)
        end
      end

      File.chmod(0755, "UnisonWatch.app/Contents/MacOS/UnisonWatch")

      system %{bin/setfileicon assets/unison.icns UnisonWatch.app}
    end

    no_tasks do
      def gem_directory
        Unison.root
      end
    end
  end
end

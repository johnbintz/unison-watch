module Unison
  class Profile
    PROFILE_DIR = File.expand_path('~/.unison')

    def self.process(profiles)
      profiles.collect { |profile| new(profile) }
    end

    def self.available
      Dir[File.join(PROFILE_DIR, '*.prf')].collect { |file| File.basename(file).gsub('.prf', '') }.sort
    end

    def initialize(which)
      @which = which
    end

    def local_root
      roots.find { |root| root[%r{^/}] }
    end

    def roots
      @roots ||= lines.find_all { |line| line[%r{^root}] }.collect { |line| value_of(line) }
    end

    def lines
      return @lines if @lines

      @lines = File.readlines(File.expand_path("~/.unison/#{@which}.prf"))

      includes = []

      @lines.each do |line|
        if file = line[%r{^include (.*)}, 1]
          includes += File.readlines(File.expand_path("~/.unison/#{file}"))
        end
      end

      @lines += includes
    end

    def paths
      @paths ||= lines.find_all { |line| line[%r{^path}] }.collect { |line| value_of(line) }
    end

    def paths_with_local_root
      paths.collect { |path| File.join(local_root, path) }
    end

    def value_of(line)
      line[%r{=(.*)$}, 1].strip
    end
  end
end


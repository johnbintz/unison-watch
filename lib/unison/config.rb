require 'yaml'
require 'atomic'

module Unison
  class Config
    def self.ensure(file)
      if !File.file?(file)
        File.open(file, 'wb') { |fh| fh.print YAML.dump(skel_data) }
      end

      new(file)
    end

    def self.skel_data
      { 'profiles' => [] }
    end

    def set_profile(profile, is_set)
      @data.update do |d|
        if is_set
          d['profiles'] << profile
        else
          d['profiles'].delete(profile)
        end

        d['profiles'].uniq!

        d
      end

      @on_update.call if @on_update

      save
    end

    def on_update(&block)
      @on_update = block
    end

    def initialize(file)
      @file = file

      @data = Atomic.new(nil)
    end

    def active?(profile)
      profiles.include?(profile)
    end

    def profiles
      data['profiles']
    end

    def data
      @data.update { |d| d || YAML.load_file(@file) }
      @data.value
    end

    def active_profiles?
      !profiles.empty?
    end

    def save
      @data.update do |d|
        File.open(@file, 'wb') { |fh| fh.print YAML.dump(d) }
        d
      end
    end
  end
end

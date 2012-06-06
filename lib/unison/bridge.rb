module Unison
  class Bridge
    def self.run(*args, &block)
      new(*args).run(&block)
    end

    def initialize(config, log)
      @config, @log = config, log
    end

    def run(&block)
      Thread.new do
        begin
          @config.profiles.each do |profile|
            system %{bash -c '#{@config.unison_binary} -ui text -log -logfile #{@log} -batch #{profile}'}

            if $?.exitstatus != 0
              system %{bash -c '#{@config.unison_binary} -ui graphic #{profile}'}
            end
          end

          block.call
        rescue => e
          puts e.message
          puts e.backtrace.join("\n")
          exit 1
        end
      end
    end
  end
end


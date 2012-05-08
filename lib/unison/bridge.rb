module Unison
  class Bridge
    def self.run(*args, &block)
      new(*args).run(&block)
    end

    def initialize(profiles, log)
      @profiles, @log = profiles, log
    end

    def run(&block)
      Thread.new do
        begin
          @profiles.each do |profile|
            #system %{bash -c 'unison -log -logfile #{@log} -batch #{profile} 2>>#{@log}.stderr >>#{@log}.stdout'}
            system %{bash -c 'unison -log -logfile #{@log} -batch #{profile}'}
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


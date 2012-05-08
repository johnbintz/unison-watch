require 'forwardable'

module Unison
  class Watcher < Qt::Application
    TRANSFER_LOG = '~/unison.log'
    SYNC_CHECK_COUNT = 600
    SYNC_CHECK_TIME = 0.1

    extend Forwardable

    def_delegators :@config, :profiles
    def initialize(profiles, *args)
      super(*args)

      @config = Unison::Config.ensure(File.expand_path('~/.unison/watch.yml'))
      @queue = Atomic.new([])

      @sync_now = false
      @exiting = false
      @active = true
      end

    def <<(dirs)
      @queue.update { |q| q += [ dirs ].flatten ; q }
    end

    def processed_profiles
      @processed_profiles ||= Unison::Profile.process(profiles)
    end

    def watch
      Unison::FilesystemWatcher.new(paths_to_watch, self)
    end

    def paths_to_watch
      processed_profiles.collect(&:paths_with_local_root).flatten
    end

    def fileview
      @fileview ||= Unison::UI::FileView.new(File.expand_path(TRANSFER_LOG))
    end

    def menu
      return @menu if @menu

      @menu = Unison::UI::Menu.new

      @menu.on(:sync_now) { @sync_now = true }
      @menu.on(:toggle_status) { toggle_status }
      @menu.on(:view_log) { fileview.show }
      @menu.on(:quit) { @exiting = true }
      @menu.on(:preferences) { preferences.show }
      @menu.generate

      @menu
    end

    def update_ui
      @icon.current_icon = @current_icon
      @menu.status_text = @current_text

      processEvents
    end

    def ui
      @icon = Unison::UI::Icon.new(menu, self, profiles, File.join(Unison.root, 'assets'))
      @config.on_update { @icon.profiles = @config.profiles }

      @current_icon = 'idle'

      toggle_status true
      @prior_text = nil

      @icons = {}

      @remote_sync_check = SYNC_CHECK_COUNT

      while !@exiting
        check

        update_ui

        sleep SYNC_CHECK_TIME
      end
    end

    def start
      if !@config.active_profiles?
        preferences.show
      end

      watch
      ui
    end

    def preferences
      @preferences ||= Unison::UI::Preferences.new(@config)
    end

    def show_working
      index = 0
      while true do
        @current_icon = "working-#{index + 1}"
        fileview.read!

        update_ui

        break if @done or @exiting

        sleep 0.25
        index = (index + 1) % 2
      end

      @current_icon = current_icon
      fileview.read!
    end

    def check
      begin
        if @active && (@queue.value.length > 0 || @remote_sync_check == 0 || @sync_now)
          dir = nil

          @current_text = "Syncing..."

          @done = false

          Unison::Bridge.run(profiles, TRANSFER_LOG) { @done = true }

          show_working

          @remote_sync_check = SYNC_CHECK_COUNT
          @sync_now = false
          @queue.update { [] }
        end
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
        exit 1
      end

      @remote_sync_check -= 1

      if @active
        @current_text = "Next check in #{sprintf("%.0d", SYNC_CHECK_TIME * @remote_sync_check)} secs."
      else
        @current_text = "Syncing paused."

        @remote_sync_check = SYNC_CHECK_COUNT
      end
    end

    def toggle_status(set = nil)
      @active = set || !@active

      @menu.active_status_text = @active ? "Pause syncing" : "Resume syncing"
      @current_icon = current_icon
    end

    def current_icon
      @active ? 'idle' : 'paused'
    end
  end
end

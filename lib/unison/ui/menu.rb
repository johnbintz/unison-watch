module Unison
  module UI
    class Menu < Qt::Menu
      IDLE = 'Unison watch idle.'
      SYNC_NOW = 'Sync now'
      PAUSE_SYNCING = 'Pause syncing'
      VIEW_TRANSFER_LOG = "View transfer log"
      QUIT = 'Quit'

      def initialize(*args)
        super(*args)

        @status_text = IDLE
      end

      def on(event, &block)
        @on ||= {}
        @on[event] = block
      end

      def generate
        generate_status

        @sync_now = Qt::Action.new(SYNC_NOW, self)
        @sync_now.connect(SIGNAL(:triggered), &@on[:sync_now])

        @active_status = Qt::Action.new(PAUSE_SYNCING, self)
        @active_status.connect(SIGNAL(:triggered), &@on[:toggle_status])

        @log = Qt::Action.new(VIEW_TRANSFER_LOG, @menu)
        @log.connect(SIGNAL(:triggered), &@on[:view_log])

        @preferences = Qt::Action.new('Preferences...', @menu)
        @preferences.connect(SIGNAL(:triggered), &@on[:preferences])

        @quit = Qt::Action.new(QUIT, @menu)
        @quit.connect(SIGNAL(:triggered), &@on[:quit])

        addAction @active_status
        addAction @sync_now
        addSeparator
        addAction @log
        addAction @preferences
        addAction @quit
      end

      def status_text=(text)
        if @status_text != text
          @status_text = text

          generate_status
        end
      end

      def active_status_text=(text)
        @active_status.text = text
      end

      def generate_status
        new_status = Qt::Action.new(@status_text, self)
        new_status.enabled = false
        insertAction(@active_status, new_status)
        removeAction(@status)

        @status = new_status
      end
    end
  end
end


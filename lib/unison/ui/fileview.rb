module Unison
  module UI
    class FileView < Qt::TextEdit
      INITIAL = "Watching for changes..."

      def initialize(file, *args)
        super(*args)

        @file = file
        @current_log_size = File.size(@file)

        self.plainText = INITIAL
        self.readOnly = true
        self.resize 800, 600
        self.connect(SIGNAL(:textChanged), &method(:on_text_change))
      end

      def show
        super
        self.raise
      end

      def on_text_change
        self.moveCursor Qt::TextCursor::End
      end

      def read!
        File.open(@file, 'r') { |fh|
          fh.seek(@current_log_size)
          self.plainText = fh.read
        }
      end
    end
  end
end


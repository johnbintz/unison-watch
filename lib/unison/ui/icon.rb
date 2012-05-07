module Unison
  module UI
    class Icon < Qt::SystemTrayIcon
      def initialize(menu, window, profiles, icon_source, *args)
        super(*args)

        self.contextMenu = menu
        @window, @icon_source, @profiles = window, icon_source, profiles

        @current_icon = nil
        @icons = {}
      end

      def qt_icon_for(name)
        @icons[name] ||= Qt::Icon.new(File.join(@icon_source, "#{name}.png"))
      end

      def large_qt_icon_for(name)
        qt_icon_for("large-#{name}")
      end

      def profiles=(profiles)
        @profiles = profiles
        set_tooltip
      end

      def current_icon=(icon)
        if icon != @current_icon
          self.icon = qt_icon_for(icon)
          @window.windowIcon = large_qt_icon_for(icon)
          set_tooltip
          show if !@current_icon

          @current_icon = icon
        end
      end

      def set_tooltip
        self.toolTip = "Unison Agent\nUsing #{@profiles.join(', ')} profile"
        show
      end
    end
  end
end


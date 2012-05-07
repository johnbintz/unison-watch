module Unison
  module UI
    class Preferences < Qt::Widget
      def initialize(config, *args)
        super(*args)

        @config = config

        generate
      end

      def generate
        layout = Qt::GridLayout.new

        profile_group = Qt::GroupBox.new("Profiles")
        profile_group_layout = Qt::VBoxLayout.new
        profile_group.setLayout(profile_group_layout)

        Unison::Profile.available.each do |profile|
          radio = Qt::CheckBox.new(profile)
          radio.checked = @config.active?(profile)
          radio.connect(SIGNAL "toggled(bool)") { |checked| @config.set_profile(profile, checked) }
          profile_group_layout.addWidget(radio)
        end

        layout.addWidget(profile_group)

        setLayout(layout)
      end
    end
  end
end

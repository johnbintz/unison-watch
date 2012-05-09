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

        performance_group = Qt::GroupBox.new("Performance")
        performance_group_layout = Qt::VBoxLayout.new
        performance_group.setLayout(performance_group_layout)

        fields = Qt::Widget.new
        fields_layout = Qt::GridLayout.new
        fields.setLayout(fields_layout)

        count_label = Qt::Label.new("Seconds between checks (min 10s):")
        count_field = Qt::LineEdit.new(@config.time_between_checks.to_s)
        count_field.connect(SIGNAL "textChanged(QString)") { |string| @config.time_between_checks = string.to_i }

        fields_layout.addWidget(count_label, 0, 0)
        fields_layout.addWidget(count_field, 0, 1)
        performance_group_layout.addWidget(fields)

        layout.addWidget(profile_group, 0, 0)
        layout.addWidget(performance_group, 0, 1)

        setLayout(layout)
      end
    end
  end
end

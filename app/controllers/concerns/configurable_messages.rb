# frozen_string_literal: true

module ConfigurableMessages
  include ApplicationConfiguration
  extend ActiveSupport::Concern

  def show_message(key, options = {})
    check_message_default(key, options[:default]) if Rails.env.test?
    flash[:message] = configured_value [:messages, key], options
  end

  private

  # in test, make sure that the default given is the default provided
  # in the application.yml.example file, if one exists.
  def check_message_default(message_name, controller_default)
    config_path = Rails.root.join 'config', 'application.yml.example'
    return unless File.exist? config_path

    example_config = YAML.load_file config_path
    messages = example_config['messages']
    return if messages.blank?

    configured_default = messages[message_name.to_s]
    return if configured_default.blank? ||
              configured_default == controller_default

    raise ArgumentError, <<-MESSAGE
      Configurable message #{message_name} has mismatched default:
      In controller file: #{controller_default}
      In #{config_path}: #{configured_default}
      Please update the application.yml.example file to match.
    MESSAGE
  end
end

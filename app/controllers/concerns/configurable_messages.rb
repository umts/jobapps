module ConfigurableMessages
  extend ActiveSupport::Concern

  def self.included(klass)
    klass.extend self
  end

  def show_message(key, options = {})
    configured_value = CONFIG[:messages][key]
    flash[:message] =
    if configured_value.present?
      configured_value
    elsif options[:default].present?
      options[:default]
    else
      raise ArgumentError,
            "Message #{key} not configured and default not specified."
    end
  end
end

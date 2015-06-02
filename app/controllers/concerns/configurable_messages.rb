module ConfigurableMessages
  extend ActiveSupport::Concern

  def ConfigurableMessages.included klass
    klass.extend ConfigurableMessages
  end

  MISSING_MESSAGE_VALUE_ERROR = ->(key){raise ArgumentError,
    'Message not given in configuration file and default was not specified.'}

  def show_message key, options = {}
    flash[:message] = CONFIG[:messages][key] ||
      options.fetch(:default, &MISSING_MESSAGE_VALUE_ERROR)
  end
end

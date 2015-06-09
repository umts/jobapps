module ConfigurableMessages
  include ApplicationConfiguration
  extend ActiveSupport::Concern

  def show_message(key, options = {})
    flash[:message] = configured_value [:messages, key], options
  end
end

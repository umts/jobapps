module ConfigurableMessages
  include ApplicationConfiguration
  extend ActiveSupport::Concern

  def self.included(klass)
    klass.extend self
  end

  def show_message(key, options = {})
    flash[:message] = configured_value [:messages, key], options
  end
end

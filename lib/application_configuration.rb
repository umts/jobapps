# frozen_string_literal: true

module ApplicationConfiguration
  extend self

  # Accepts an array of symbols corresponding to the key path
  # at which to reach the desired value in application.yml.
  # For instance [:a, :b] would query CONFIG[:a][:b].
  # Optionally, although most of the time, accepts an options
  # hash containing a default value in the case where one is not
  # configured.
  def configured_value(config_path, options = {})
    value = CONFIG.dig(*config_path)
    # dig returns {} when key not found
    # because CONFIG is a special, different kind of hash
    # but, it is possible that a query will yield false
    # as a configured value, so we cannot use .present?
    #
    # CONFIG.dig with a missing top-level key returns {}
    # but with a missing lower-level key within a top-level key that does exist,
    # returns nil
    if !value.nil? && value != {} then value
    elsif options.key? :default then options[:default]
    else
      raise ArgumentError,
            "Configuration behavior #{config_path} not configured
            and default not specified."
    end
  end
end

module ApplicationConfiguration
  # Accepts an array of symbols corresponding to the key path
  # at which to reach the desired value in application.yml.
  # For instance [:a, :b] would query CONFIG[:a][:b].
  # Optionally, although most of the time, accepts an options
  # hash containing a default value in the case where one is not
  # configured.
  def configured_value(config_path, options = {})
    value = CONFIG.dig(*config_path)
    # dig returns nil when key not found
    # but, it is possible that a query will yeild false
    # as a configured value, so we cannot use .present?
    if !value.nil? then value
    elsif options[:default].present? then options[:default]
    else
      raise ArgumentError,
            "Configuration behavior #{config_path} not configured
            and default not specified."
    end
  end

  def yamlize(string)
    string.underscore.tr(' ', '_').to_sym
  end
end

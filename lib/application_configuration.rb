module ApplicationConfiguration
  def configured_value(config_path, options = {})
    value = CONFIG
    config_path.each do |key|
      value = value[key]
    end
    if value.present?
      value
    elsif options[:default].present?
      options[:default]
    else
      raise ArgumentError,
            "Configuration behavior #{config_path} not configured
            and default not specified."
    end
  end
end

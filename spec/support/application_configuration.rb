# frozen_string_literal: true

def stub_config(*config_path, value)
  raise ArgumentError if config_path.blank?

  config = CONFIG.dup
  key = config_path.pop
  config_path.reduce(config) { |a, b| a[b] ||= {} }[key] = value

  stub_const('CONFIG', config)
end

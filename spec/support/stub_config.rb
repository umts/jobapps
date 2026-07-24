# frozen_string_literal: true

# Overrides a value in config/app.yml (exposed as config.x.app) for the
# duration of an example, e.g.
# stub_config(:on_application_denial, :notify_applicant, false).
def stub_config(*config_path, value)
  raise ArgumentError if config_path.blank?

  overrides = config_path.reverse.reduce(value) { |nested, key| { key => nested } }
  merged = Rails.configuration.x.app.to_h.deep_merge(overrides)
  allow(Rails.configuration.x).to receive(:app).and_return(ActiveSupport::OrderedOptions.new.update(merged))
end

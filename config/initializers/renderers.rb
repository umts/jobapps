# frozen_string_literal: true

ActionController::Renderers.add :pdf do |obj, options|
  data = obj.respond_to?(:render) ? obj.render : obj.to_s
  filename = options[:filename] || 'report'
  disposition = options[:disposition].presence || 'inline'
  send_data data, type: Mime[:pdf], filename: "#{filename}.pdf", disposition: disposition
end

# frozen_string_literal: true

module ApplicationSubmissionHelper
  def format_response(response, type)
    return '' if response.blank?

    case type
    when 'date'
      response.to_date.to_fs
    else
      response
    end
  end
end

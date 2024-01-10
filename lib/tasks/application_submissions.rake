# frozen_string_literal: true

def parse_date(date)
  return if date.blank?

  begin
    Date.strptime(date, '%m/%d/%Y')
  rescue Date::Error
    Date.parse(date)
  end
end

namespace :application_submissions do
  desc 'Correct date format for previous submissions'
  task fix_submitted_dates: :environment do
    ApplicationSubmission.find_each do |as|
      as.update! data: (as.data.map do |question|
        case question
        in [prompt, response, 'date', id]
          [prompt, parse_date(response)&.to_formatted_s(:db), 'date', id]
        else
          question
        end
      end)
    end
  end
end

# frozen_string_literal: true

def parse_date(date)
  return '' if date.blank?

  begin
    Date.strptime(date, '%m/%d/%Y')
  rescue Date::Error
    begin
      Date.parse(date)
    rescue Date::Error
      false
    end
  end
end

namespace :application_submissions do
  desc 'Correct date format for previous submissions'
  task fix_submitted_dates: :environment do
    ApplicationSubmission.find_each do |as|
      as.update! data: (as.data.map do |question|
        case question
        in [prompt, response, 'date', *rest]
          date = parse_date(response)
          if date
            [prompt, date.presence&.to_formatted_s(:db), 'date', *rest]
          else
            [prompt, response, 'text', *rest]
          end
        else
          question
        end
      end)
    end
  end
end

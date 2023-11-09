# frozen_string_literal: true

namespace :application_submission do
  desc 'Update old EEO ethnicities to the new wording'
  task update_ethnicity: :environment do
    ApplicationSubmission.each do |app|
      case app.ethnicity
      when 'Black (Not of Hispanic origin)'
        app.update ethnicity: 'Black or African American (Not of Hispanic origin)'
      when 'American Indian or Alaskan Native'
        app.update ethnicity: 'American Indian/Alaska Native'
      when 'Hispanic'
        app.update ethnicity: 'Hispanic or Latino'
      when 'Mixed ethnicity'
        app.update ethnicity: 'Multiracial'
      else
        next
      end
    end
  end
end

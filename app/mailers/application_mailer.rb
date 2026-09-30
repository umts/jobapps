# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'
  layout 'umts/brand/mailer'
end

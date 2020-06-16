class AddResumeUploadEnabledToApplicationTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :application_templates, :resume_upload_enabled, :boolean, default: false
  end
end

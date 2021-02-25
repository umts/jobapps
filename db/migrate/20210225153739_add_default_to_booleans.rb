class AddDefaultToBooleans < ActiveRecord::Migration[6.0]
  def change
    [
      %i[application_submissions reviewed],
      %i[application_templates unavailability_enabled],
      %i[interviews hired],
      %i[interviews completed],
      %i[questions required],
      %i[users staff],
      %i[users admin]
    ].each do |table, column|
      change_column_default table, column, from: nil, to: false
    end
  end
end

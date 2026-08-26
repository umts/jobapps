# frozen_string_literal: true

# simplecov:disable
module Maintenance
  class ImportEntraUidsTask < MaintenanceTasks::Task
    csv_collection

    def process(row)
      User.find_by!(spire: "#{row['spire_id']}@umass.edu").update!(entra_uid: "#{row['entra_uid']}#{tenant_id}")
    end

    private

    def tenant_id = Rails.application.credentials.entra_id.tenant_id
  end
end
# simplecov:enable

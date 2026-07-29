# frozen_string_literal: true

# simplecov:disable
module Maintenance
  class ImportEntraUidsTask < MaintenanceTasks::Task
    csv_collection

    def process(row)
      User.find_by!(spire: "#{row['spire_id']}@umass.edu").update!(entra_uid: row['entra_uid'])
    end
  end
end
# simplecov:enable

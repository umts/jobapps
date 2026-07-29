# frozen_string_literal: true

# simplecov:disable
module Maintenance
  class FillMissingEntraUidsTask < MaintenanceTasks::Task
    def collection
      User.where(entra_uid: nil)
    end

    def process(user)
      user.update!(entra_uid: "missing-#{user.spire.delete_suffix('@umass.edu')}")
    end
  end
end
# simplecov:enable

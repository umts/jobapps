every :day do
  runner 'ApplicationRecord.move_records_to_pending'
end


# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  include UMTS::Auth::Current
end

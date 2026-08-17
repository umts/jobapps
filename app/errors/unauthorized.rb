# frozen_string_literal: true

# Raised by access-control callbacks when the current user (or lack thereof) is
# not permitted to perform the requested action. Rescued globally in
# ApplicationController, which renders the login page (no session) or a
# forbidden page (authenticated but not permitted).
class Unauthorized < StandardError; end

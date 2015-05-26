class AccessDeniedException < Exception
  def initialize msg = "You have insufficient privileges to access this resource. If you believe this message to be in error, please contact the system administrator."
    super
  end
end

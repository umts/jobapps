# frozen_string_literal: true

# Sets current user based on two acceptable values:
# 1. a symbol name of a user factory trait;
# 2. a specific instance of User.
def when_current_user_is(user)
  current_user =
    case user
    when Symbol then create :user, user
    when User then user
    when nil then nil
    else raise ArgumentError, 'Invalid user type'
    end
  set_current_user current_user
end

# Helper method, sets the current user based on spec type
def set_current_user(user)
  case self.class.metadata[:type]
  when :view
    assign :current_user, user
  when :feature, :system
    page.set_rack_session user_id: user.try(:id)
  when :controller
    if user.present?
      session[:user_id] = user.id
    else
      session[:spire] = build(:user).spire
    end
  end
end

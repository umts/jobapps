# frozen_string_literal: true

# Sets current user based on two acceptable values:
# 1. a symbol name of a user factory trait;
# 2. a specific instance of User.
def when_current_user_is(user)
  current_user =
    case user
    when :anyone, :anybody then create(:user)
    when Symbol then create(:user, user)
    when User, nil then user
    else raise ArgumentError, 'Invalid user type'
    end
  set_current_user current_user
end

# Helper method, sets the current user based on spec type
# rubocop:disable Naming/AccessorMethodName
def set_current_user(user)
  case self.class.metadata[:type]
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
# rubocop:enable Naming/AccessorMethodName

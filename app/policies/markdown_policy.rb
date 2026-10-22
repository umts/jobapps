# frozen_string_literal: true

class MarkdownPolicy < ApplicationPolicy
  def manage? = logged_in?
end

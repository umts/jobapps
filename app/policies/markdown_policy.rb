# frozen_string_literal: true

class MarkdownPolicy < ApplicationPolicy
  def manage? = staff?
end

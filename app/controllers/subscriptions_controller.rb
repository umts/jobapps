# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def create
    @subscription = Subscription.new subscription_parameters
    @subscription.save
    redirect_back_or_to edit_position_path(@subscription.position)
  end

  def destroy
    @subscription = Subscription.find params.require :id
    @subscription.destroy
    redirect_back_or_to edit_position_path(@subscription.position)
  end

  private

  def subscription_parameters
    params.expect subscription: %i[email position_id user_id]
  end
end

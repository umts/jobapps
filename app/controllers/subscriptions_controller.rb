class SubscriptionsController < ApplicationController
  def create
    @subscription = Subscription.new subscription_parameters
    @subscription.save
    redirect_back fallback_location: edit_position_path(@subscription.position)
  end

  def destroy
    @subscription = Subscription.find params.require :id
    @subscription.destroy
    redirect_back fallback_location: edit_position_path(@subscription.position)
  end

  private

  def subscription_parameters
    params.require(:subscription).permit :email,
                                         :position_id,
                                         :user_id
  end
end

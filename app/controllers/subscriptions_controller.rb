class SubscriptionsController < ApplicationController

  def create
    @subscription = Subscription.new subscription_parameters
    @subscription.save!
    redirect_to :back
  end

  def destroy
    params.require :id
    @subscription = Subscription.find params[:id]
    @subscription.destroy
    redirect_to :back
    #TODO: show flash message (you have been unsubscribed)
  end

  private

  def subscription_parameters
    params.require(:subscription).permit :email,
                                         :position_id,
                                         :user_id
  end
end

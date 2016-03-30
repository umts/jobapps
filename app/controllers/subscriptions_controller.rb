class SubscriptionsController < ApplicationController
  def create
    @subscription = Subscription.new

  end
  def create
    binding.pry
    @subscription = Subscription.new subscription_parameters
    redirect_to :back
  end

    # TODO Make it mail stuff?
    # TODO add the email value that the user enters to sub.
    # TODO create new subscription
    # Subscription.new
    # user_id = current_user.id - from params?
    # email = user input
    # position_id = @position.find params[:id]
  # redirect to back
  private
  def subscription_parameters
    params.require(:subscription).permit :email,
                                         :position_id,
                                         :user_id
  end
end

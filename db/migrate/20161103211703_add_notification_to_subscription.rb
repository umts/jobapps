class AddNotificationToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :notification, :boolean
  end
end

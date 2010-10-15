class OrderObserver < ActiveRecord::Observer
  def after_update(order)
    return unless order.recently_paid?
    StoreMailer.deliver_order_confirmation(order)
  end
  
  def after_save(order)
    return unless order.recently_shipped?
    StoreMailer.deliver_tracking_number_confirmation(order)
  end
end
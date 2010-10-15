class StoreMailer < ApplicationMailer

  def order_confirmation(order)
    setup_email(order.user)
    subject       "Edison Nation - Order Confirmation"
    body          :user => order.user, :order => order
  end
  
  def tracking_number_confirmation(order)
    setup_email(order.user)
    subject       'Edison Nation - Your order has shipped!'
    body          :user => order.user, :order => order
  end
end
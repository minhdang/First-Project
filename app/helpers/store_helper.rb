module StoreHelper
  
  def readable_product_type_option(product_type)
    price = users_price(product_type)
    "#{h(product_type.name)} - #{number_to_currency(price)} + #{number_to_currency(product_type.shipping)} S&H"
  end
  
  def users_price(product_type)
    (logged_in? && current_user.member? && product_type.member_price) ? product_type.member_price : product_type.price
  end
  
end
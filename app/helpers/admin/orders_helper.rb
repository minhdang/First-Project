module Admin::OrdersHelper
  
  def carrier_options
    App.shipping_carriers.keys.collect {|carrier| [carrier.to_s.titleize, carrier.to_s]}
  end

end
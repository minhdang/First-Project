module PaymentHelper
  def cc_type_selector(form_helper)
    form_helper.select :cc_type, [['Visa', 'visa'],['MasterCard','master']]
  end
  
  def cc_exp_month_selector(form_helper)
    months = (1..12).to_a
    form_helper.select :cc_exp_month, months.map {|m| [("%02d" % m), m]}
  end
  
  def cc_exp_year_selector(form_helper)
    start_y = Time.now.year
    end_y   = start_y + 10 # 10 years from now
    years = (start_y..end_y).to_a
    form_helper.select :cc_exp_year, years.map {|y| [y,y]}
  end

end
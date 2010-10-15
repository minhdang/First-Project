module MoneyHelper
  def currency_or_free(amount)
    amount && amount != 0.0 ? number_to_currency(amount) : "free"
  end
end
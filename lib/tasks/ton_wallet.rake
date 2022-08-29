namespace 'ton_wallet' do
  def honeybadger_check_in
    return unless Rails.env.production?

    Net::HTTP.get_response(URI('https://api.honeybadger.io/v1/check_in/vOI4Qx'))
  end

  task complete_purchases: :environment do
    CompletePurchasesService.call
    honeybadger_check_in
  end
end

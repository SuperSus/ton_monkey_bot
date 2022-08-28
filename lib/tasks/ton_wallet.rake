namespace 'ton_wallet' do
  task complete_purchases: :environment do
    CompletePurchasesService.call
  end
end

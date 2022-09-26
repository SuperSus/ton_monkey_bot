# frozen_string_literal: true

class CompletePurchasesService
  class << self
    def call
      new.call
    end
  end

  # @return [Array<Purchase>] completed purchases
  def call
    purchases_to_complete.filter_map do |purchase|
      success = purchase.with_lock do
        transaction = message_to_transaction_mapping[purchase.comment]
        purchase.process_payment(nanocoins: transaction.nanocoins, wallet_address: transaction.wallet_address)
      end
      next unless success

      notify_user(purchase)
      purchase
    end
  end

  private

  def purchases_to_complete
    @purchases_to_complete ||= Purchase.uncompleted.where(comment: message_to_transaction_mapping.keys).order(:id)
  end

  def message_to_transaction_mapping
    @message_to_transaction_mapping ||= wallet.transactions.index_by(&:comment)
  end

  def wallet
    @wallet ||= WalletService.new
  end

  def notify_user(purchase)
    Telegram.bot.send_message(chat_id: purchase.user.telegram_id, text: "Спасибо за покупку #{purchase.quantity} NFT!")
  end
end

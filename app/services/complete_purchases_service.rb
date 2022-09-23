# frozen_string_literal: true

class CompletePurchasesService
  class << self
    def call
      new.call
    end
  end

  # @return [Array<Purchase>] completed purchases
  def call
    node_process.exec!
    handle_error(node_process.err) if node_process.err.present?

    complete_purchases
  end

  private

  def complete_purchases
    purchases_to_complete = Purchase.uncompleted.where(comment: message_to_transaction_mapping.keys)
    purchases_to_complete.filter_map do |purchase|
      success = purchase.with_lock do
        transaction_params = message_to_transaction_mapping[purchase.comment]
        purchase.process_payment(**transaction_params)
      end
      next unless success

      notify_user(purchase)
      purchase
    end
  end

  def message_to_transaction_mapping
    @message_to_transaction_mapping ||= transactions.map do |transaction|
      params = { nanocoins: transaction['amount'].to_i, wallet_address: transaction['sourceAddress'] }
      [transaction['message'], params]
    end.to_h
  end

  def transactions
    @transactions ||= parse_transactions
  end

  def parse_transactions
    return {} if node_process.out.blank?

    JSON(node_process.out)
  end

  def node_process
    @node_process ||=
      POSIX::Spawn::Child.build('node', 'get_wallet_transactions.js', Rails.application.credentials[:wallet_address],
                                Rails.application.credentials[:tonweb_api_key])
  end

  def notify_user(purchase)
    Telegram.bot.send_message(chat_id: purchase.user.telegram_id, text: "Спасибо за покупку #{purchase.quantity} NFT!")
  end

  def handle_error(err)
    return if err.blank?

    Rails.logger.error(err)
    raise err
  end
end

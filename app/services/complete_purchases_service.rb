class CompletePurchasesService
  class << self
    def call
      new.call
    end
  end

  def call
    node_process.exec!
    complete_purchases
  end

  private

  def complete_purchases
    messages = transactions.map { _1['message'] }
    purchases_to_complete = Purchase.uncompleted.where(comment: messages)
    purchases_to_complete.each do |purchase|
      purchase.completed!
      notify_user(purchase)
    end
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
      POSIX::Spawn::Child.build('node', 'get_wallet_transactions.js', Rails.application.credentials[:wallet_address], Rails.application.credentials[:tonweb_api_key])
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

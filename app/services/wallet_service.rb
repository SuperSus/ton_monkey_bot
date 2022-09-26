# frozen_string_literal: true

class WalletService
  def transactions
    @transactions ||= parse_transactions.map do |transaction|
      OpenStruct.new(
        comment: transaction['message'],
        nanocoins: transaction['amount'].to_i,
        wallet_address: transaction['sourceAddress']
      )
    end
  end

  private

  def parse_transactions
    node_process_exec!
    return {} if node_process.out.blank?

    JSON(node_process.out)
  end

  def node_process_exec!
    node_process.exec!
    handle_error(node_process.err) if node_process.err.present?
  end

  def node_process
    @node_process ||=
      POSIX::Spawn::Child.build(
        'node', 'nft_deployer/get_wallet_transactions.js',
        Rails.application.credentials.dig(:wallet, :address),
        Rails.application.credentials[:tonweb_api_key]
      )
  end

  def handle_error(err)
    return if err.blank?

    Rails.logger.error(err)
    raise err
  end
end

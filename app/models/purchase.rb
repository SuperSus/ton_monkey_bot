class Purchase < ApplicationRecord
  TOTAL_NFT_COUNT = 5000
  DEFAULT_NFT_PRICE = 0.01
  MAX_PER_USER_NFT_COUNT = 100
  NANOCOINS_IN_TON = 100_000_0000
  PRECISION_IN_NANOCOINS = 10_000

  class << self
    def nft_price
      DEFAULT_NFT_PRICE
    end

    def total_nft_count
      TOTAL_NFT_COUNT
    end

    def available_nft_count
      total_nft_count - completed.sum(:quantity)
    end

    def max_per_user_nft_count
      MAX_PER_USER_NFT_COUNT
    end

    def wallet_address
      Rails.application.credentials[:wallet_address]
    end
  end

  delegate :wallet_address, to: :class

  belongs_to :user

  enum status: { uncompleted: 'uncompleted' , completed: 'completed' }, _default: "uncompleted"

  before_validation :set_comment
  before_validation :set_price

  validates :comment, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0, less_than: MAX_PER_USER_NFT_COUNT }

  def check_payment(nanocoins:, comment:)
    valid_amount = (nanocoins_price - nanocoins.to_i).abs <= PRECISION_IN_NANOCOINS
    valid_comment = self.comment == comment.strip

    valid_amount && valid_comment
  end

  def nanocoins_price
    (price * NANOCOINS_IN_TON).to_i
  end

  def tonkeeper_payment_link
    "https://app.tonkeeper.com/transfer/#{wallet_address}?amount=#{nanocoins_price}&text=#{comment}"
  end

  private

  def set_comment
    self.comment ||= SecureRandom.hex(6)
  end

  def set_price
    self.price ||= quantity * DEFAULT_NFT_PRICE
  end
end

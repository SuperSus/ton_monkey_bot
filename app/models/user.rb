class User < ApplicationRecord
  has_many :purchases
  belongs_to :referrer, optional: true, class_name: 'User'

  validates :telegram_id, presence: :true
  validate :validate_referrer

  def referrals_count
    User.where(referrer_id: id).count
  end

  private

  def validate_referrer
    return if referrer_id.blank?

    errors[:referrer_id].add('Invalid referrer') if referrer_id == id
  end
end

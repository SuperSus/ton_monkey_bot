class User < ApplicationRecord
  belongs_to :referrer, optional: true, class_name: 'User'

  validates :telegram_id, presence: :true
  validate :validate_referrer

  private

  def validate_referrer
    return if referrer_id.blank?

    errors[:referrer_id].add('Invalid referrer') if referrer_id == id
  end
end

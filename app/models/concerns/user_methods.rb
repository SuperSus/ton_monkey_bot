module UserMethods
  def current_user
    @current_user ||= User.find_by(telegram_id: from['id'])
  end

  def create_user
    return if current_user.present?

    @current_user = User.create(user_params)
    @current_user.tap { _1 Rails.logger.error("#{_1.errors.full_messages}, payload: #{payload}") if _1.errors.any? }
  end

  def user_params
    @user_params ||= begin
      result = from
                .transform_keys { _1 == 'id' ? :telegram_id : _1.to_sym }
                .slice(:first_name, :last_name, :username, :telegram_id)
      referrer = User.find_by(telegram_id: session[:referrer_telegram_id]) if session[:referrer_telegram_id]
      result.tap { _1.merge!(referrer: referrer) if referrer }
    end
  end

  def save_referrer
    session[:referrer_telegram_id] = payload['text'].scan(/\d+/).last
  end
end

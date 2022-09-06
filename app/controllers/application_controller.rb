class ApplicationController < ActionController::Base
  rescue_from StandardError do |e|
    # e.message - sentry
    logger.error e.message
    logger.error e.backtrace.join("\n")
    # flash[:error] = "Попробуй еще раз!"
    # redirect_back fallback_location: root_path
  end

  private

  def logger
    Rails.logger
  end
end

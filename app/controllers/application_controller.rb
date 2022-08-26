class ApplicationController < ActionController::Base
  rescue_from StandardError do |e|
    # e.message - sentry
    flash[:error] = "Попробуй еще раз!"
    redirect_back fallback_location: root_path
  end
end

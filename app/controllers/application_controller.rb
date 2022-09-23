class ApplicationController < ActionController::Base
  # rescue_from StandardError do |e|
  #   logger.error e.message
  #   logger.error e.backtrace.join("\n")
  #   redirect_back fallback_location: root_path
  # end

  private

  def logger
    Rails.logger
  end
end

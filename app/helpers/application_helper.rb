module ApplicationHelper
  def inline_error_for(field, form_obj)
    html = []

    if form_obj.errors[field].any?
      html << form_obj.errors[field].map do |msg|
        tag.div(msg, class: "text-red-400 text-xs m-0 p-0 text-right mb-2")
      end
    end

    html.join.html_safe
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash"
  end

  def render_payment_page
    turbo_stream.replace 'purchase', partial: @purchase&.completed? ? 'success' : 'payment_form'
  end
end

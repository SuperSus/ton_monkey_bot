# frozen_string_literal: true

class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session

  self.session_store = :file_store, Rails.root.join('tmp/cache')

  ICONS = {
    edit: "\xE2\x9C\x8F",
    industry: "\xF0\x9F\x92\xBC",
    check: "\xE2\x9C\x85",
    rocket: "\xF0\x9F\x9A\x80",
    back_arrow: "\xE2\x86\xA9",
    credit_card: "\xF0\x9F\x92\xB3",
    instruction: "\xF0\x9F\x93\x96",
    search: "\xF0\x9F\x94\x8D",
    settings: "\xF0\x9F\x94\xA7",
    link_arrow: "\xE2\x86\x97"
  }.freeze

  MAIN_MENU = {
    history:    "История #{ICONS[:rocket]}",
    settings:   "Настройки #{ICONS[:settings]}",
    references: "Ссылки #{ICONS[:link_arrow]}",
    faq:        "FAQ #{ICONS[:instruction]}",
  }

  use_session!

  def message(message)
    # store_message(message['text'])
  end

  # For the following types of updates commonly used params are passed as arguments,
  # full payload object is available with `payload` instance method.
  #
  #   message(payload)
  #   inline_query(query, offset)
  #   chosen_inline_result(result_id, query)
  #   callback_query(data)

  def start!(_word = nil, *_other_words)
    respond :message, text: greeting
    if captcha_resolved? # or current_user.present?
      save_keyboard_context
    else
      save_context :resolve_captcha
      send_captcha
    end
  end

  def keyboard!(value = nil, *)
    case value
    when /история/i
      respond :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'Наша История'
    when /настройки/i
      respond :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'Настройки'
    when /ссылки/i
      respond :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'Cсылки'
    when /faq/i
      respond :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'FAQ'
    else
      respond :message, text: 'хз'
    end
    save_keyboard_context
  end

  def save_keyboard_context
    save_context :keyboard!
  end

  def send_captcha(response_answer = nil, *)
    equation, answer = CaptchaService.captcha
    session[:captcha] = { equation: equation, answer: answer, resolved: false}
    save_context :resolve_captcha
    respond :message, text: "Для начала решите уравнение #{equation}"
  end

  def resolve_captcha(answer = nil, *)
    result = CaptchaService.check(equation: session[:captcha][:equation], answer: answer)
    if result
      save_keyboard_context
      session[:captcha][:resolved] = true
      respond :message, text: 'Отлично, стартуем!'

      return
    end

    respond :message, text: 'Неверно ;) пробуй еще раз!'
    send_captcha
  end

  private

  def captcha_resolved?
    session[:captcha].try(:[], :resolved)
  end

  def respond(*args, **kws)
    respond_with *args, kws.merge(reply_markup: main_menu)
  end

  def main_menu
    buttons = [
      [MAIN_MENU[:history], MAIN_MENU[:references]],
      [MAIN_MENU[:settings], { text: MAIN_MENU[:faq], web_app: { url: 'https://supersus.github.io/monkey_bot_faq/' } }],
    ]
    {
      keyboard: buttons,
      resize_keyboard: true,
      one_time_keyboard: false,
      selective: true,
    }
  end

  def greeting
    from ? "Привет #{from['username']}!" : 'Привет!'
  end
end

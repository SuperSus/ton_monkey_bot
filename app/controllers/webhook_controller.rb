# frozen_string_literal: true

class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include Telegram::Bot::UpdatesController::Session
  include UserMethods

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
    link_arrow: "\xE2\x86\x97",
    map: "\xF0\x9F\x9A\x8F",
  }.freeze

  MAIN_MENU = {
    history:    "История #{ICONS[:rocket]}",
    settings:   "Настройки #{ICONS[:settings]}",
    references: "Ссылки #{ICONS[:link_arrow]}",
    faq:        "FAQ #{ICONS[:instruction]}",
    roadmap:    "Roadmap #{ICONS[:map]}",
    minter:     "Minter #{ICONS[:credit_card]}"
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
    respond_with :message, text: greeting
    if current_user.present?
      save_keyboard_context
    else
      save_referrer
      send_captcha
    end
  end

  def keyboard!(value = nil, *)
    case value
    when /история/i
      respond_with_keyboard :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'Наша История'
    when /настройки/i
      respond_with_keyboard :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'Настройки'
    when /ссылки/i
      respond_with_keyboard :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'Cсылки'
    when /faq/i
      respond_with_keyboard :photo, photo: File.open(Rails.root.join('lol.webp').to_s), caption: 'FAQ'
    when /roadmap/i
    when /minter/i
      respond_with_keyboard :message, text: "Бот для минта\n\n@minter111_bot"
    else
    end
  ensure
    save_keyboard_context
  end

  def save_keyboard_context
    save_context :keyboard!
  end

  def send_captcha(_message = nil, *)
    equation, answer = CaptchaService.captcha
    session[:captcha] = { equation: equation, answer: answer, resolved: false}
    save_context :resolve_captcha
    respond_with :message, text: "Для начала реши уравнение #{equation}"
  end

  def resolve_captcha(answer = nil, *)
    result = CaptchaService.check(equation: session[:captcha][:equation], answer: answer)
    if result
      save_keyboard_context
      session[:captcha][:resolved] = true
      create_user
      respond_with_keyboard :message, text: 'Отлично, стартуем!'

      return
    end

    respond_with :message, text: 'Неверно ;) попробуй еще раз!'
    send_captcha
  end

  private

  def registered?
    current_user.present? || session[:captcha].try(:[], :resolved)
  end

  def respond_with_keyboard(*args, **kws)
    respond_with *args, kws.merge(reply_markup: main_menu)
  end

  def main_menu
    buttons = [
      [MAIN_MENU[:history], MAIN_MENU[:references]],
      [ MAIN_MENU[:settings], MAIN_MENU[:minter] ],
      [
        { text: MAIN_MENU[:faq], web_app: { url: 'https://supersus.github.io/monkey_bot_faq/' } },
        { text: MAIN_MENU[:roadmap], web_app: { url: 'https://monkeybusiness.yummiwannaplay.com/roadmap' } }
      ]
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

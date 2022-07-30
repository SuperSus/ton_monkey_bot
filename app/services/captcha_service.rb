# frozen_string_literal: true

module CaptchaService
  EQUATIONS = {
    '(5 - 2) * 3' => 9,
    '(6 + 2) * 2' => 16,
    '(2 + 3 + 1) / 2' => 3,
    '(9 - 4) * 2' => 10,
    '2 * (7 - 4)' => 6,
    '3 * (1 + 2)' => 9,
    '5 * (4 + 2 - 5)' => 5
  }.freeze

  module_function

  # @return [String, Integer]
  def captcha
    EQUATIONS.to_a[rand(EQUATIONS.size)]
  end

  # @param [String] equation
  # @param [String] answer
  #
  # @return [Boolean]
  def check(equation:, answer:)
    EQUATIONS[equation] == answer.to_i
  end
end

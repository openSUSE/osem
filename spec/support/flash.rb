# frozen_string_literal: true

module Flash
  def flash
    results = all(:css, 'div#flash p')
    return 'none' if results.empty?
    if results.count > 1
      texts = results.map(&:text)
      raise "One flash expected, but we had #{texts.inspect}"
    end
    results.first.text
  end
end

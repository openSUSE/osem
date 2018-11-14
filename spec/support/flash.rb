# frozen_string_literal: true

module Flash
  def flash
    results = all(:css, 'div#flash p')
    if results.empty?
      return 'none'
    end

    if results.count > 1
      texts = results.map { |r| r.text }
      fail "One flash expected, but we had #{texts.inspect}"
    end
    results.first.text
  end
end

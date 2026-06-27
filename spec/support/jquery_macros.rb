# frozen_string_literal: true

module JQueryMacros
  # Wait for one jQuery Ajax request during the block
  def wait_for_ajax
    flag = "window.ajax_#{SecureRandom.alphanumeric(16)}"
    page.execute_script "#{flag} = false; $(document).one('ajaxComplete', () => #{flag} = true);"

    yield

    Timeout.timeout(Capybara.default_max_wait_time) { loop until page.evaluate_script(flag) }
    page.execute_script "delete #{flag};"
  end
end

# frozen_string_literal: true

RSpec.configure do |config|
  config.after(:each, type: :feature) do
    example_filename = RSpec.current_example.full_description
    example_filename = example_filename.tr(' ', '_')
    example_filename = File.expand_path(example_filename, Capybara.save_path)
    example_screenshotname = "#{example_filename}.png"
    example_filename += '.html'
    if RSpec.current_example.exception.present?
      save_page(example_filename)
      save_screenshot(example_screenshotname) # rubocop:disable Lint/Debugger
    # remove the file if the test starts working again
    else
      File.unlink(example_filename) if File.exist?(example_filename)
      File.unlink(example_screenshotname) if File.exist?(example_screenshotname)
    end
  end
end

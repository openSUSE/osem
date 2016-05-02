# Automatically save the page a test fails
Capybara.save_and_open_page_path = Rails.root.join('tmp', 'capybara')

RSpec.configure do |config|
  config.after(:each, type: :feature) do
    example_filename = RSpec.current_example.full_description
    example_filename = example_filename.tr(' ', '_')
    example_filename = example_filename + '.html'
    example_filename = File.expand_path(example_filename, Capybara.save_and_open_page_path)
    if RSpec.current_example.exception.present?
      save_page(example_filename)
    # remove the file if the test starts working again
    elsif File.exist?(example_filename)
      File.unlink(example_filename)
    end
  end
end

# Automatically save and open the page
# whenever an expectation is not met in a features spec
RSpec.configure do |config|
  config.after(:each, type: :feature) do
    ename = RSpec.current_example.full_description
    ename = ename.gsub ' ', '_'
    ename.downcase!
    ename = ename + '.html'
    if RSpec.current_example.exception.present?
      save_page(ename)
    else
      capfile = File.expand_path(ename, Capybara.save_and_open_page_path)
      if File.exist?(capfile)
        File.unlink(capfile)
      end
    end
  end
end

module LoginMacros
  def sign_in(user)
    visit new_user_session_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    find(:xpath, "//div[@id='content']//button[@type='submit']").click

    expect(page.has_content?('Signed in successfully')).to be true
  end

  def sign_out
    Capybara.current_session.driver.browser.clear_cookies
    visit root_path
    expect(page.has_content?('Sign In')).to be true
  end
end

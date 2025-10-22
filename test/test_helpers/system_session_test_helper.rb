module SystemSessionTestHelper
  def sign_in_as(user)
    session = user.sessions.create!(user_agent: "system-test-browser", ip_address: "127.0.0.1")
    cookie_value = build_signed_session_cookie(session.id)

    visit root_path
    add_session_cookie_to_browser(cookie_value)
    visit root_path
  end

  def sign_out
    page.driver.browser.manage.delete_cookie("session_id")
  rescue Selenium::WebDriver::Error::NoSuchCookieError
    # Already signed out in the browser, nothing else to do.
  end

  private

    def build_signed_session_cookie(session_id)
      cookie_jar = ActionDispatch::TestRequest.create.cookie_jar
      cookie_jar.signed[:session_id] = session_id
      cookie_jar[:session_id]
    end

    def add_session_cookie_to_browser(cookie_value)
      browser = page.driver.browser
      browser.manage.delete_cookie("session_id") rescue nil
      browser.manage.add_cookie(name: "session_id", value: cookie_value, path: "/")
    end
end

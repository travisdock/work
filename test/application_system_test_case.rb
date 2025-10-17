require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
    driver_option.add_argument("--no-sandbox")
    driver_option.add_argument("--disable-dev-shm-usage")
    driver_option.add_argument("--disable-gpu")
    driver_option.add_argument("--remote-debugging-port=0")
    driver_option.add_argument("--user-data-dir=/tmp/chrome_test_#{Process.pid}_#{Time.now.to_i}")
  end

  def sign_in_as(user)
    visit sign_in_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_on "Sign In"
    # Wait for successful sign-in and redirect
    assert_current_path root_path
  end
end

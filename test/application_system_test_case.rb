require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemSessionTestHelper

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
    driver_option.add_argument("--no-sandbox")
    driver_option.add_argument("--disable-dev-shm-usage")
    driver_option.add_argument("--disable-gpu")
    driver_option.add_argument("--remote-debugging-port=0")
    driver_option.add_argument("--user-data-dir=/tmp/chrome_test_#{Process.pid}_#{Time.now.to_i}")
  end

  setup do
    sign_in_as(system_test_user) if system_test_user
  end

  private

    def system_test_user
      users(:one)
    end
end

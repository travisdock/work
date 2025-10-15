ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Authentication helper for controller tests
    def sign_in_as(user)
      post sign_in_url, params: { email_address: user.email_address, password: "password" }
    end
  end
end

class ActionDispatch::IntegrationTest
  # Authentication helper for integration and system tests
  def sign_in_as(user)
    post sign_in_url, params: { email_address: user.email_address, password: "password" }
  end
end

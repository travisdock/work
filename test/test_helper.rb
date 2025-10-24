ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "active_support/testing/time_helpers"
require_relative "test_helpers/session_test_helper"
require_relative "test_helpers/system_session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include ActiveSupport::Testing::TimeHelpers
  end
end

class ActionDispatch::IntegrationTest
  include SessionTestHelper
end

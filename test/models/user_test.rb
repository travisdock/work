require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires email_address to be present" do
    user = User.new(password: "averysecurepassword")

    assert_predicate user, :invalid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "requires unique email_address ignoring case" do
    existing = users(:one)
    user = User.new(email_address: existing.email_address.upcase, password: "averysecurepassword")

    assert_predicate user, :invalid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "requires valid email format" do
    user = User.new(email_address: "not-an-email", password: "averysecurepassword")

    assert_predicate user, :invalid?
    assert_includes user.errors[:email_address], "must be a valid email address"
  end

  test "requires password length of at least 12 characters when provided" do
    user = User.new(email_address: "new@example.com", password: "shortpass")

    assert_predicate user, :invalid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "allows shorter passwords in development environment" do
    Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
      user = User.new(email_address: "dev@example.com", password: "shortpass")

      assert_predicate user, :valid?
    end
  end
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.valid?
  end

  test "should require email_address" do
    user = User.new(password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should require valid email format" do
    user = User.new(
      email_address: "invalid-email",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "should require unique email_address" do
    # Alice already exists in fixtures
    user = User.new(
      email_address: users(:alice).email_address,
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should enforce case-insensitive email uniqueness" do
    User.create!(
      email_address: "UNIQUE@EXAMPLE.COM",
      password: "password123",
      password_confirmation: "password123"
    )

    user = User.new(
      email_address: "unique@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should normalize email_address to lowercase" do
    user = User.create!(
      email_address: "  UPPERCASE@EXAMPLE.COM  ",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_equal "uppercase@example.com", user.email_address
  end

  test "should strip whitespace from email_address" do
    user = User.create!(
      email_address: "  spaces@example.com  ",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_equal "spaces@example.com", user.email_address
  end

  test "should require password for new records" do
    user = User.new(email_address: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should require password minimum length of 8 characters" do
    user = User.new(
      email_address: "test@example.com",
      password: "short",
      password_confirmation: "short"
    )
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "should authenticate with correct password" do
    user = User.create!(
      email_address: "auth@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.authenticate("password123")
    assert_not user.authenticate("wrongpassword")
  end

  test "should allow password updates" do
    user = users(:alice)
    user.password = "newpassword123"
    user.password_confirmation = "newpassword123"
    assert user.save
    assert user.authenticate("newpassword123")
  end

  test "should allow updates without changing password" do
    user = users(:alice)
    user.email_address = "newemail@example.com"
    assert user.save
  end

  test "should have many projects" do
    user = users(:alice)
    assert_respond_to user, :projects
    assert_equal 1, user.projects.count
    assert_includes user.projects, projects(:one)
  end

  test "should have many tasks" do
    user = users(:alice)
    assert_respond_to user, :tasks
    assert user.tasks.count > 0
  end

  test "should destroy associated projects when destroyed" do
    user = users(:alice)
    project_count = user.projects.count
    assert project_count > 0

    assert_difference "Project.count", -project_count do
      user.destroy
    end
  end

  test "should destroy associated tasks when destroyed" do
    user = users(:alice)
    task_count = user.tasks.count
    assert task_count > 0

    assert_difference "Task.count", -task_count do
      user.destroy
    end
  end
end

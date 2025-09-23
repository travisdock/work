require "test_helper"

class TaskDependenciesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get task_dependencies_create_url
    assert_response :success
  end

  test "should get destroy" do
    get task_dependencies_destroy_url
    assert_response :success
  end
end

require 'test_helper'

class RootControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_index_url
    assert_response :success
  end

  test "should get callback" do
    get root_callback_url
    assert_response :success
  end

  test "should get logout" do
    get root_logout_url
    assert_response :success
  end

end

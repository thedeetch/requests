require 'test_helper'

class RequestUsersControllerTest < ActionController::TestCase
  setup do
    @request_user = request_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_user" do
    assert_difference('RequestUser.count') do
      post :create, request_user: { request_id: @request_user.request_id, user_id: @request_user.user_id }
    end

    assert_redirected_to request_user_path(assigns(:request_user))
  end

  test "should show request_user" do
    get :show, id: @request_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @request_user
    assert_response :success
  end

  test "should update request_user" do
    put :update, id: @request_user, request_user: { request_id: @request_user.request_id, user_id: @request_user.user_id }
    assert_redirected_to request_user_path(assigns(:request_user))
  end

  test "should destroy request_user" do
    assert_difference('RequestUser.count', -1) do
      delete :destroy, id: @request_user
    end

    assert_redirected_to request_users_path
  end
end

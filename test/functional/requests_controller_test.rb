require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  setup do
    @request = requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request" do
    assert_difference('Request.count') do
      post :create, request: { behalf_of_user: @request.behalf_of_user, category: @request.category, description: @request.description, priority: @request.priority, size: @request.size, status: @request.status, target_date: @request.target_date, title: @request.title, type: @request.type, user: @request.user }
    end

    assert_redirected_to request_path(assigns(:request))
  end

  test "should show request" do
    get :show, id: @request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @request
    assert_response :success
  end

  test "should update request" do
    put :update, id: @request, request: { behalf_of_user: @request.behalf_of_user, category: @request.category, description: @request.description, priority: @request.priority, size: @request.size, status: @request.status, target_date: @request.target_date, title: @request.title, type: @request.type, user: @request.user }
    assert_redirected_to request_path(assigns(:request))
  end

  test "should destroy request" do
    assert_difference('Request.count', -1) do
      delete :destroy, id: @request
    end

    assert_redirected_to requests_path
  end
end

require 'test_helper'

class RequestCommentsControllerTest < ActionController::TestCase
  setup do
    @request_comment = request_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_comment" do
    assert_difference('RequestComment.count') do
      post :create, request_comment: { request_id: @request_comment.request_id, text: @request_comment.text, user_id: @request_comment.user_id }
    end

    assert_redirected_to request_comment_path(assigns(:request_comment))
  end

  test "should show request_comment" do
    get :show, id: @request_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @request_comment
    assert_response :success
  end

  test "should update request_comment" do
    put :update, id: @request_comment, request_comment: { request_id: @request_comment.request_id, text: @request_comment.text, user_id: @request_comment.user_id }
    assert_redirected_to request_comment_path(assigns(:request_comment))
  end

  test "should destroy request_comment" do
    assert_difference('RequestComment.count', -1) do
      delete :destroy, id: @request_comment
    end

    assert_redirected_to request_comments_path
  end
end

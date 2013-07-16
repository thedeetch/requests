require 'test_helper'

class RequestAttachmentsControllerTest < ActionController::TestCase
  setup do
    @request_attachment = request_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_attachment" do
    assert_difference('RequestAttachment.count') do
      post :create, request_attachment: { request_id: @request_attachment.request_id }
    end

    assert_redirected_to request_attachment_path(assigns(:request_attachment))
  end

  test "should show request_attachment" do
    get :show, id: @request_attachment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @request_attachment
    assert_response :success
  end

  test "should update request_attachment" do
    put :update, id: @request_attachment, request_attachment: { request_id: @request_attachment.request_id }
    assert_redirected_to request_attachment_path(assigns(:request_attachment))
  end

  test "should destroy request_attachment" do
    assert_difference('RequestAttachment.count', -1) do
      delete :destroy, id: @request_attachment
    end

    assert_redirected_to request_attachments_path
  end
end

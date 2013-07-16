require 'test_helper'

class RequestTeamsControllerTest < ActionController::TestCase
  setup do
    @request_team = request_teams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_teams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_team" do
    assert_difference('RequestTeam.count') do
      post :create, request_team: {  }
    end

    assert_redirected_to request_team_path(assigns(:request_team))
  end

  test "should show request_team" do
    get :show, id: @request_team
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @request_team
    assert_response :success
  end

  test "should update request_team" do
    put :update, id: @request_team, request_team: {  }
    assert_redirected_to request_team_path(assigns(:request_team))
  end

  test "should destroy request_team" do
    assert_difference('RequestTeam.count', -1) do
      delete :destroy, id: @request_team
    end

    assert_redirected_to request_teams_path
  end
end

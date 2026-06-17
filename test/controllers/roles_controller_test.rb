require "test_helper"

class RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  test "should get index" do
    get roles_url
    assert_response :success
  end

  test "should get new" do
    get new_role_url
    assert_response :success
  end

  test "should create role" do
    @item = Role.new(name: "Test Role", is_active: true)
    assert_difference("Role.count") do
      post roles_url, params: { role: { is_active: @item.is_active, name: @item.name } }
    end

    assert_redirected_to role_url(Role.last)
  end

  test "should show role" do
    @item = Role.all.first
    get role_url(@item)
    assert_response :success
  end

  test "should get edit" do
    @item = Role.all.first
    get edit_role_url(@item)
    assert_response :success
  end

  test "should update role" do
    @item = Role.all.first
    patch role_url(@item), params: { role: { is_active: @item.is_active, name: @item.name } }
    assert_redirected_to role_url(@item)
  end

  test "should destroy role" do
    @item = Role.all.first
    assert_difference("Role.count", -1) do
      delete role_url(@item)
    end

    assert_redirected_to roles_url
  end
end

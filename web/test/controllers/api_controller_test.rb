require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  test "should get analyze" do
    post analyze_api_index_url, params: { data: { test: 1 } }
    assert_response :success
  end

  test "should get analyze_bytecode" do
    post analyze_bytecode_api_index_url, params: { data: { test: 1 } }
    assert_response :success
  end

end
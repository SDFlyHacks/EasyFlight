require 'test_helper'

class FlightInfoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get flight_info_index_url
    assert_response :success
  end

end

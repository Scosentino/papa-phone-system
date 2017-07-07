require 'test_helper'
require 'webmock/minitest'

class KatAppTest < ActiveSupport::TestCase
  def setup
    @success_body = "{\"success\":\"Booking request created\"}"

    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(
        :post, 'http://katapp.dev/api/v1/create_booking?api_key=764be5ea-a1bb-4df7-8f82-753665bff759&booking_type=Tradeshow&budget=A&business=yes%20-%20Smith%20Co&date=tomorrow&email=test@email.com&hours=ten&name=Smith&phone=19998889999&talent=20'
    ).with(
        headers: {
            'Authorization'=>'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.jcvdm1JX-96hE_FvzlNsts5vrBmghwc6Q46EsTD0KT8'}
    ).to_return(
        status: 201,
        body: @success_body,
        headers: {})

    @booking = bookings(:one)
    @response = KatApp.server("http://katapp.dev/api/v1/create_booking", @booking)
  end

  def test_successful_creation_of_booking_request
    assert_equal @success_body, @response.body
  end
end
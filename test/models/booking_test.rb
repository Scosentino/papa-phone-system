require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  setup do
    @booking = bookings(:one)
    @invalid_booking = bookings(:two)
  end

  test 'saves valid bookings' do
    assert @booking.valid?
  end

  test "don't save invalid bookings" do
    assert !@invalid_booking.valid?
  end
end

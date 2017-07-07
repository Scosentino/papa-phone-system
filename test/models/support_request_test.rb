require 'test_helper'

class SupportRequestTest < ActiveSupport::TestCase
  setup do
   @support_request = support_requests(:one)
   @invalid_request = support_requests(:two)
  end

  test "valid support request saves" do
    assert @support_request.valid?
  end

  test "support request doesn't save without twilio contact" do
    assert !@invalid_request.valid?
  end
end

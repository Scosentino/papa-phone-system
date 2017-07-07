require 'test_helper'

class SupportRequestMailerTest < ActionMailer::TestCase
  setup do
    @contact = twilio_contacts(:one)
  end

  test 'notify support' do
    email = SupportRequestMailer.notify_support(@contact, 'A - Test details').deliver
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['quinn@thekatagency.com'], email.from
    assert_equal ['sean@thekatagency.com'], email.to
    assert_equal '[Quinn] You have a support request from a client', email.subject
  end
end

require 'twilio-ruby'
require 'sanitize'


class TwilioController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    render text: "Dial Me."
  end

  # POST ivr/welcome
  def ivr_welcome
    welcome = 'Hello, Welcome to the Kat Agency. '
    message = 'If you are a client press 9 for immediate support. For Application support, Press 1. For inquiries, press 2. For all other inquiries, please email hello at the kat agency dot calm.'
    response = Twilio::TwiML::Response.new do |r|
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Say welcome + message, voice: 'alice', language: 'en-GB'
        g.Pause(length: 5)
        g.Say message, voice: 'alice', language: 'en-GB'
        g.Pause(length: 5)
      end
      r.Say "I'm sorry. I haven't received a response. Please try again later.", voice: 'alice', language: 'en-GB'
      r.Hangup
    end
    render text: response.text
  end

  # GET ivr/selection
  def menu_selection
    kat = '+14432041282'
    sean = '+13057266671'
    jordan = '+14156016003'
    user_selection = params['Digits']

    case user_selection
    when '1' then twiml_connect('Connecting you to our booking department. One moment please.', kat)
    when '2' then twiml_connect('Connecting you to our application support. One moment please.', sean)
    when '3' then twiml_connect('Connecting you to our tech support. One moment please.', sean)
    when '4' then twiml_connect('Connecting you to Kat Quinn. One moment please.', kat)
    when '5' then twiml_connect('Connecting you to Jordan. One moment please.', jordan)
    when '6' then twiml_connect('Connecting you to Sean Cosentino. One moment please.', sean)
    when '9' then twiml_connect('One moment while I connect you.', sean)
    else else_statement
    end
  end

  private

  def else_statement
    message = "I'm sorry. That was an invalid choice. Please try again. If you are a client press 9 for immediate support. For Application support, Press 1. For inquiries, press 2. For all other inquiries, please email hello at the kat agency dot calm."
    response = Twilio::TwiML::Response.new do |r|
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Say message, voice: 'alice', language: 'en-GB'
        g.Pause(length: 5)
        g.Say message, voice: 'alice', language: 'en-GB'
        g.Pause(length: 5)
      end
      r.Say "I'm sorry. I haven't received a response. Please try again later.", voice: 'alice', language: 'en-GB'
      r.Hangup
    end

    render text: response.text
  end
  def twiml_say(phrase)
    response = Twilio::TwiML::Response.new do |r|
      r.Say phrase, voice: 'alice', language: 'en-GB'
    end

    render text: response.text
  end

  def twiml_dial(phone_number)
    response = Twilio::TwiML::Response.new do |r|
      r.Dial phone_number
    end

    render text: response.text
  end

  def twiml_connect(output, phone_number)
    response = Twilio::TwiML::Response.new do |r|
      r.Say output, voice: 'alice', language: 'en-GB'
      r.Dial phone_number
    end

    render text: response.text
  end
end

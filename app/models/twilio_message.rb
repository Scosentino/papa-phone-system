class TwilioMessage < ActiveRecord::Base
  WELCOME_MESSAGE = <<EOF
Hello my name is Lisa and Welcome to PAPA!
EOF
  INSTRUCTIONS = <<EOF
If you would like to make a Booking Request, Reply ‘Booking’
To get in contact with a real human, type ‘Contact’
To connect with Technology Support, reply ‘Support’
EOF
  STAFF_NUMBERS = {
      'andrew' => '+17542240411'
      'sean' => '+13057266671',

  }
  INVALID_RESPONSE = "Sorry that was an invalid response try again or type 'Main Menu'"

  # Todo - Need to add correct staff phone numbers.

  belongs_to :twilio_contact
  attr_accessor :contact

  def save_and_respond(from_number, to_number, message_body)
    process_message(from_number, to_number,message_body)
    save_message(from_number, to_number, message_body, 'incoming')
  end

  def process_message(from_number, to_number, body)
    if body =~ /^main menu$/i
      if @contact = TwilioContact.find_by(phone: from_number)
        set_type(@contact, 'welcome')
        send_message(from_number)
      end
    else
      if @contact = TwilioContact.find_by(phone: from_number)
        # first check for type set?
        case type
          # If type set to welcome, look at body of message
          when /welcome/i
            case body
              when /^booking$/i then booking(from_number, body)
              when /^contact$/i then contact(from_number, body)
              when /^support$/i then support(from_number, body)
              else send_message(from_number, INVALID_RESPONSE)
            end
          # Else route accordingly
          when /booking/i then booking(from_number, body)
          when /contact/i then contact(from_number, body)
          when /support/i then support(from_number, body)
          else send_message(from_number, INVALID_RESPONSE)
        end
      else
        # If first time reaching out, create contact and send welcome messages.
        @contact = TwilioContact.create!(phone: from_number, sms_step: {type: 'welcome', step: 1}.to_json.to_s )
        send_message(from_number, WELCOME_MESSAGE)
        send_message(from_number)
      end
    end
  end

  def booking(from_number, body)
    # Create Booking model and save responses
    set_type(@contact, 'booking')
    case step
      when 1
        # Create Booking Record
        Booking.create!(twilio_contact: @contact)
        booking_response(from_number, 'To create a booking, please reply with your name', step)
      when 2
        # Save Name to Booking Record
        @contact.bookings.last.update(name: body)
        booking_response(from_number, 'What is your email?',  step)
      when 3
        # Save email to Booking Record
        @contact.bookings.last.update(email: body)
        booking_response(from_number, 'What is your phone number?',  step)
      when 4
        if !booking_business
          # Save phone number
          @contact.bookings.last.update(phone: body)
          send_message(from_number, 'Is the booking for a business? (yes/no)')
          set_booking_business(@contact, 4)
        else
          case body
            when /yes/i
              # Save business choice to database
              @contact.bookings.last.update(business: body)
              booking_response(from_number, 'What is the business name?', step)
            else
              booking = @contact.bookings.last
              if booking.business
                booking.update(business: "#{booking.business} - #{body}")
              else
                booking.update(business: body)
              end
              booking_response(from_number, 'Please select from the following Booking Types: Inside, Outside', step + 1)
          end
        end
      when 5
        #Save business response in case of no
        @contact.bookings.last.update(business: body)
        booking_response(from_number, 'Please select from the following Booking Types: Inside, Outside', step)
      when 6
        # Save booking type
        @contact.bookings.last.update(booking_type: body)
        booking_response(from_number, 'What is the date of this booking?',  step)
      when 7
        # save date of booking
        @contact.bookings.last.update(date: body)
        booking_response(from_number, 'How many hours is the event?', step)
      when 8
        # save hours
        @contact.bookings.last.update(hours: body)
        booking_response(from_number, 'How many talent do you need?', step)
      when 9
        # save amount of talent
        @contact.bookings.last.update(talent: body)
        booking_response(from_number, 'What is your budget, A: Less than $5,000 | B: Greater than $5,000?', step)
      when 10
        # Save last piece of booking information and send to lisaApp
        booking = @contact.bookings.last
        booking.update(budget: body)
        lisaApp.server(ENV['lisa_app_booking_request_url'], booking)
        send_message(from_number, 'Great! Thanks for the information. We\'ll be reaching out shortly.')
        set_type(@contact, 'welcome')
        send_message(from_number, 'Going back to the main menu.')
        send_message(from_number, INSTRUCTIONS)
      else
        send_message(from_number, INVALID_RESPONSE)
    end
  end

  def contact(number, body)
    # IF type is set to Contact, continue messaging thread
    if type =~ /contact/i
      case body
        when /^lisa$/i then forward_contact('lisa', number)
        when /^andrew$/i then forward_contact('andrew', number)
        when /^sean$/i then forward_contact('sean', number)
        else send_message(number, INVALID_RESPONSE)
      end
    else
      set_type(@contact, 'contact')
      send_message(number, "Thank you for reaching out, to speak with one of our experts please reply with the name of the person whom you’d like to speak with. (lisa, Andrew, Sean)")
    end
  end

  def support(number,body)
    if type =~ /support/i
      case support_type
        when /talent/i
          SupportRequest.create!(twilio_contact: @contact, contact_type: 'talent', details: body)
          send_message(number, "Please Describe the Issue.")
          set_answered(@contact)
        when /answered/i
          request = @contact.support_requests.last
          request.update!(details: "#{request.details} - #{body}")
          send_message("+13057266671", request.details)
          send_message(number, "Thank you for that information. We'll reach out to you ASAP.")
          set_type(@contact, 'welcome')
        when /client/i
          request = SupportRequest.create!(twilio_contact: @contact, contact_type: 'client', details: body)
          SupportRequestMailer.notify_support(@contact, request.details).deliver
          send_message(number, "Thank you for that information. We'll reach out to you ASAP.")
          set_type(@contact, 'welcome')
        else
          case body
            when /call now/i
              send_message("+13057266671", "Hi Support, #{number} requested an immediate call.")
            when /talent/i
              send_message(number, "please pick from the following: a: application, b: profile, c: account access, d: other")
              set_support_type(@contact, 'talent')
            when /client/i
              send_message(number, "please describe the issue you are having.")
              set_support_type(@contact, 'client')
            else
              send_message(number, INVALID_RESPONSE)
          end
      end
    else
      set_type(@contact, 'support')
      send_message(number,'Having issues and need immediate assistance, reply call now to receive a phone call from support immediately. Otherwise, are you a Talent or Client, please reply "Talent" or "Client"')
    end
  end

  def unknown_message(number, body = "I'm sorry. I don't understand what you mean. Please try again.Please try again.")
    send_message(number, body)
    send_message(number)
  end

  def send_message(recepient_number, message_body = INSTRUCTIONS, phone_number = ENV['TWILIO_PHONE_NUMBER'])
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    save_message(phone_number, recepient_number, message_body, 'outgoing')
    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.account.messages.create({
                                        :from => phone_number,
                                        :to => recepient_number,
                                        :body => message_body
                                    })
  end

  private

  def increment_step(contact, type, step)
    contact.update!(sms_step: {type: type.downcase, step: step + 1}.to_json.to_s)
  end

  def set_type(contact, type)
    unless json(contact.sms_step)[:type] == type
      contact.update!(sms_step: {type: type.downcase, step: 1}.to_json.to_s)
    end
  end

  def set_staff_name(contact, staff_name)
    contact.update!(sms_step: {type: 'contact', step: 1, staff_name: staff_name.downcase}.to_json.to_s)
  end

  def set_support_type(contact, type)
    contact.update!(sms_step: {type: 'support', step: 1, support_type: type.downcase}.to_json.to_s)
  end

  def set_answered(contact)
    contact.update!(sms_step: {type: 'support', step: 1, support_type: 'answered'}.to_json.to_s)
  end

  def set_booking_business(contact, step)
    contact.update!(sms_step: {type: 'booking', step: step.to_i, booking_business: true}.to_json.to_s)
  end

  def json(string)
    JSON.parse(string ,symbolize_names: true)
  end

  def booking_business
    json(@contact.sms_step)[:booking_business]
  end

  def step
    json(@contact.sms_step)[:step].to_i
  end

  def type
    json(@contact.sms_step)[:type]
  end

  def staff_name
    json(@contact.sms_step)[:staff_name]
  end

  def support_type
    json(@contact.sms_step)[:support_type]
  end

  def save_message(from, to, body, type)
    TwilioMessage.create!(from_number: from, to_number: to, message_body: body, message_type: type, twilio_contact: @contact)
  end

  def remove_staff_contact(staff)
    if c = TwilioContact.find_by(sms_contact: staff)
      c.update!(sms_contact: nil)
    end
  end

  def booking_response(number, message, step)
    send_message(number, message)
    increment_step(@contact, 'booking', step)
  end

  def forward_contact(staff_first_name, from_number)
    send_message(from_number, "#{staff_first_name.capitalize} has been notified and will message you shortly.")
    send_message(STAFF_NUMBERS[staff_first_name], "The following contact would like you to message them. #{from_number}")
    set_type(@contact, 'welcome')
  end
end

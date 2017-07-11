require 'httparty'

class lisaApp
  include HTTParty

  def self.server(url, booking)
    headers = {
        'Authorization' => ENV['lisa_app_admin_token']
    }
    params = {
        api_key: ENV['lisa_app_admin_api_key'],
        name: booking.name,
        email: booking.email,
        phone: booking.phone,
        business: booking.business,
        booking_type: booking.booking_type,
        date: booking.date,
        hours: booking.hours,
        talent: booking.talent,
        budget: booking.budget
    }
    post(url, query: params, headers: headers)
  end
end

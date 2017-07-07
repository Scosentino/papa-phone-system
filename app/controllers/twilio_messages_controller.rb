class TwilioMessagesController < ApplicationController
  protect_from_forgery except: [:incoming]

  def incoming
    TwilioMessage.new.save_and_respond(params[:From], params[:To], params[:Body])
    head :ok
  end

end
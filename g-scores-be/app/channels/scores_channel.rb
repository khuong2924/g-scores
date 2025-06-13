class ScoresChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "Client subscribed to ScoresChannel"
    
    # Subscribe to all score updates
    stream_from "scores"
    Rails.logger.info "Subscribed to general scores stream"

    # Subscribe to specific student's score updates if registration number is provided
    if params[:registration_number].present?
      stream_from "student_#{params[:registration_number]}_scores"
      Rails.logger.info "Subscribed to student scores stream for registration number: #{params[:registration_number]}"
    end
  end

  def unsubscribed
    Rails.logger.info "Client unsubscribed from ScoresChannel"
    stop_all_streams
  end

  def receive(data)
    Rails.logger.info "Received data on ScoresChannel: #{data.inspect}"
  end
end
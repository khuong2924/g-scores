class ScoresChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to all score updates
    stream_from "scores"

    # Subscribe to specific student's score updates
    if params[:registration_number].present?
      stream_from "student_#{params[:registration_number]}_scores"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
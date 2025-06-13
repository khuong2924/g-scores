class Api::ScoresController < ApplicationController
    def index
      unless params[:registration_number].present?
        render json: { error: 'Registration number is required' }, status: :bad_request
        return
      end
  
      student = Student.find_by(registration_number: params[:registration_number])
      unless student
        render json: { error: 'Student not found' }, status: :not_found
        return
      end
  
      scores = student.scores.includes(:subject).map do |score|
        {
          subject_name: score.subject.name,
          score: score.score
        }
      end
  
      render json: scores
    end
  end
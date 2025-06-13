class Api::ScoresController < ApplicationController
    def index
      if params[:registration_number].present?
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
      else
        # Return all scores if no registration number is provided
        scores = Score.includes(:student, :subject).map do |score|
          {
            student_name: score.student.name,
            registration_number: score.student.registration_number,
            subject_name: score.subject.name,
            score: score.score
          }
        end
      end
  
      render json: scores
    end
  end
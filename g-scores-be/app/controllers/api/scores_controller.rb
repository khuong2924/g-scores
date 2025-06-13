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
        render json: { data: scores }
      else
        # Return paginated scores if no registration number is provided
        scores_relation = Score.includes(:student, :subject)
                              .page(params[:page])
                              .per(params[:per_page] || 20)
  
        # Get pagination metadata before mapping
        pagination = {
          current_page: scores_relation.current_page,
          total_pages: scores_relation.total_pages,
          total_count: scores_relation.total_count,
          per_page: scores_relation.limit_value
        }
  
        # Map the scores after getting pagination metadata
        scores = scores_relation.map do |score|
          {
            student_name: score.student.name,
            registration_number: score.student.registration_number,
            subject_name: score.subject.name,
            score: score.score
          }
        end
  
        render json: {
          data: scores,
          pagination: pagination
        }
      end
    end
  end
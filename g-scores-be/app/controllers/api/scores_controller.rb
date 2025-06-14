class Api::ScoresController < ApplicationController
    def index
      if params[:registration_number].present?
        raw_score = RawScore.find_by(registration_number: params[:registration_number])
        unless raw_score
          render json: { error: 'Student not found' }, status: :not_found
          return
        end
  
        scores = [
          { subject_name: 'Toán', score: raw_score.toan },
          { subject_name: 'Ngữ Văn', score: raw_score.ngu_van },
          { subject_name: 'Ngoại Ngữ', score: raw_score.ngoai_ngu },
          { subject_name: 'Vật Lý', score: raw_score.vat_li },
          { subject_name: 'Hóa Học', score: raw_score.hoa_hoc },
          { subject_name: 'Sinh Học', score: raw_score.sinh_hoc },
          { subject_name: 'Lịch Sử', score: raw_score.lich_su },
          { subject_name: 'Địa Lý', score: raw_score.dia_li },
          { subject_name: 'GDCD', score: raw_score.gdcd }
        ].reject { |s| s[:score].nil? }
  
        render json: { data: scores }
      else
        # Return paginated scores if no registration number is provided
        raw_scores = RawScore.page(params[:page]).per(params[:per_page] || 20)
  
        # Get pagination metadata before mapping
        pagination = {
          current_page: raw_scores.current_page,
          total_pages: raw_scores.total_pages,
          total_count: raw_scores.total_count,
          per_page: raw_scores.limit_value
        }
  
        # Map the scores after getting pagination metadata
        scores = raw_scores.map do |raw_score|
          {
            student_name: raw_score.name,
            registration_number: raw_score.registration_number,
            scores: [
              { subject_name: 'Toán', score: raw_score.toan },
              { subject_name: 'Ngữ Văn', score: raw_score.ngu_van },
              { subject_name: 'Ngoại Ngữ', score: raw_score.ngoai_ngu },
              { subject_name: 'Vật Lý', score: raw_score.vat_li },
              { subject_name: 'Hóa Học', score: raw_score.hoa_hoc },
              { subject_name: 'Sinh Học', score: raw_score.sinh_hoc },
              { subject_name: 'Lịch Sử', score: raw_score.lich_su },
              { subject_name: 'Địa Lý', score: raw_score.dia_li },
              { subject_name: 'GDCD', score: raw_score.gdcd }
            ].reject { |s| s[:score].nil? }
          }
        end
  
        render json: {
          data: scores,
          pagination: pagination
        }
      end
    end
  end
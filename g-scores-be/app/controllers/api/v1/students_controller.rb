module Api
  module V1
    class StudentsController < ApplicationController
      BATCH_SIZE = 1000

      def search
        student = Student.find_by(registration_number: params[:registration_number])
        if student
          render json: student, include: { scores: { include: :subject } }
        else
          render json: { error: 'Không tìm thấy kết quả' }, status: :not_found
        end
      end

      def statistics
        subjects = %w[TOAN NGU_VAN VAT_LI HOA_HOC SINH_HOC LICH_SU DIA_LI GDCD NGOAI_NGU]
        statistics = {}

        subjects.each do |subject_code|
          statistics[subject_code] = Student.score_distribution_by_subject(subject_code)
        end

        render json: statistics
      end

      def top_students_group_a
        students = Student.top_students_group_a
        render json: students, include: { scores: { include: :subject } }
      end

      def import_csv
        if params[:file].blank?
          render json: { error: 'No file uploaded' }, status: :bad_request and return
        end

        begin
          # Save file to temporary location
          temp_file = Tempfile.new(['import', '.csv'])
          temp_file.binmode
          temp_file.write(params[:file].read)
          temp_file.rewind

          # Enqueue background job
          CsvImportWorker.perform_async(temp_file.path)

          render json: {
            message: "Import started",
            status: "processing"
          }, status: :accepted
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        ensure
          temp_file.close
        end
      end

      private

      def process_batch(batch)
        return if batch.empty?

        ActiveRecord::Base.transaction do
          batch.each do |record|
            student = Student.find_or_create_by!(registration_number: record[:student][:registration_number]) do |s|
              s.name = record[:student][:name]
            end

            scores = []
            record[:scores].each do |score_data|
              score = student.scores.find_or_initialize_by(subject_id: score_data[:subject_id])
              score.score = score_data[:score]
              score.english_level = score_data[:english_level] if score_data[:english_level].present?
              score.save!
              scores << score
            end

            # Broadcast batch update for this student
            ScoreBroadcastService.broadcast_batch_update(student.id, scores)
          end
        end
      end
    end
  end
end 
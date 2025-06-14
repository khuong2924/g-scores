module Api
  module V1
    class StudentsController < ApplicationController
      BATCH_SIZE = 1000

      def search
        raw_score = RawScore.find_by(registration_number: params[:registration_number])
        if raw_score
          render json: {
            registration_number: raw_score.registration_number,
            name: raw_score.name,
            scores: {
              toan: raw_score.toan,
              ngu_van: raw_score.ngu_van,
              ngoai_ngu: raw_score.ngoai_ngu,
              ma_ngoai_ngu: raw_score.ma_ngoai_ngu,
              vat_li: raw_score.vat_li,
              hoa_hoc: raw_score.hoa_hoc,
              sinh_hoc: raw_score.sinh_hoc,
              lich_su: raw_score.lich_su,
              dia_li: raw_score.dia_li,
              gdcd: raw_score.gdcd
            }
          }
        else
          render json: { error: 'Không tìm thấy kết quả' }, status: :not_found
        end
      end

      def statistics
        subjects = %w[TOAN NGU_VAN VAT_LI HOA_HOC SINH_HOC LICH_SU DIA_LI GDCD NGOAI_NGU]
        statistics = {}

        subjects.each do |subject_code|
          statistics[subject_code] = RawScore.score_distribution_by_subject(subject_code.downcase)
        end

        render json: statistics
      end

      def top_students_group_a
        students = RawScore.top_students_group_a
        render json: students
      end

      def import_csv
        if params[:file].blank?
          render json: { error: 'No file uploaded' }, status: :bad_request and return
        end

        begin
          # Create tmp directory if it doesn't exist
          tmp_dir = Rails.root.join('tmp', 'csv_imports')
          FileUtils.mkdir_p(tmp_dir)

          # Save file to shared volume
          file_path = File.join(tmp_dir, "import_#{Time.now.to_i}.csv")
          File.open(file_path, 'wb') do |file|
            file.write(params[:file].read)
          end

          # Enqueue background job
          RawScoreImportWorker.perform_async(file_path)

          render json: {
            message: "Import started",
            status: "processing"
          }, status: :accepted
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
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
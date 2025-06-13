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

        file = params[:file]
        imported = 0
        errors = []
        batch = []
        start_time = Time.current

        begin
          # Map CSV columns to subject codes
          subject_mapping = {
            'toan' => 'TOAN',
            'ngu_van' => 'NGU_VAN',
            'ngoai_ngu' => 'NGOAI_NGU',
            'vat_li' => 'VAT_LI',
            'hoa_hoc' => 'HOA_HOC',
            'sinh_hoc' => 'SINH_HOC',
            'lich_su' => 'LICH_SU',
            'dia_li' => 'DIA_LI',
            'gdcd' => 'GDCD'
          }

          # Preload all subjects to avoid N+1 queries
          subjects = Subject.where(code: subject_mapping.values).index_by(&:code)

          CSV.foreach(file.path, headers: true) do |row|
            begin
              student_data = {
                registration_number: row['sbd'],
                name: "Student #{row['sbd']}"
              }

              scores_data = []
              subject_mapping.each do |csv_column, subject_code|
                next unless row[csv_column].present?
                subject = subjects[subject_code]
                next unless subject

                score_data = {
                  subject_id: subject.id,
                  score: row[csv_column]
                }

                if subject_code == 'NGOAI_NGU' && row['ma_ngoai_ngu'].present?
                  score_data[:english_level] = row['ma_ngoai_ngu']
                end

                scores_data << score_data
              end

              batch << { student: student_data, scores: scores_data }
              imported += 1

              if batch.size >= BATCH_SIZE
                process_batch(batch)
                batch = []
              end
            rescue => e
              errors << { row: row.to_h, error: e.message }
            end
          end

          # Process remaining records
          process_batch(batch) if batch.any?

          duration = Time.current - start_time
          render json: {
            message: "Import completed",
            imported: imported,
            errors: errors,
            duration: duration.round(2)
          }, status: :ok
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

            record[:scores].each do |score_data|
              score = student.scores.find_or_initialize_by(subject_id: score_data[:subject_id])
              score.score = score_data[:score]
              score.english_level = score_data[:english_level] if score_data[:english_level].present?
              score.save!
            end
          end
        end
      end
    end
  end
end 
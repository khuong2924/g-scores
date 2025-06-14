class CsvChunkProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'csv_import', retry: 3

  BATCH_SIZE = 10_000

  def perform(chunk_path)
    Rails.logger.info("Processing chunk: #{chunk_path}")
    
    begin
      students_batch = []
      scores_batch = []
      errors = []
      processed_count = 0
      
      # Preload all subjects to avoid N+1 queries
      subjects = Subject.where(code: SUBJECT_MAPPING.values).index_by(&:code)
      
      CSV.foreach(chunk_path, headers: true) do |row|
        begin
          if valid_row?(row)
            student_data, scores_data = process_row(row, subjects)
            students_batch << student_data
            
            # Process students batch first
            if students_batch.size >= BATCH_SIZE
              bulk_insert_students(students_batch)
              students_batch = []
            end
            
            # Then process scores for the current student
            if scores_data.any?
              # Find or create student
              student = Student.find_or_create_by!(registration_number: row['sbd']) do |s|
                s.name = "Student #{row['sbd']}"
              end
              
              scores_data.each do |score_data|
                score_data[:student_id] = student.id
                scores_batch << score_data
              end
              
              if scores_batch.size >= BATCH_SIZE
                bulk_insert_scores(scores_batch)
                scores_batch = []
              end
            end
            
            processed_count += 1
            # Log progress every 1000 records
            Rails.logger.info("Processed #{processed_count} records") if processed_count % 1000 == 0
          else
            errors << { row: row.to_h, error: "Invalid row: missing registration number" }
          end
        rescue => e
          errors << { row: row.to_h, error: e.message }
          # Only log errors for debugging
          Rails.logger.error("Error processing row #{row['sbd']}: #{e.message}") if Rails.env.development?
        end
      end
      
      # Process remaining records
      bulk_insert_students(students_batch) if students_batch.any?
      bulk_insert_scores(scores_batch) if scores_batch.any?
      
      # Update progress in Redis
      redis = Redis.new
      redis.incr('csv_import_completed_chunks')
      
      # Store errors in Redis for later retrieval
      if errors.any?
        redis.rpush('csv_import_errors', errors.to_json)
      end
      
    rescue => e
      Rails.logger.error("Chunk processing failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    ensure
      # Cleanup chunk file
      File.delete(chunk_path) if File.exist?(chunk_path)
    end
  end

  private

  def process_row(row, subjects)
    student_data = {
      registration_number: row['sbd'],
      name: "Student #{row['sbd']}"
    }

    scores_data = []
    SUBJECT_MAPPING.each do |csv_column, subject_code|
      # Skip if the column is empty or nil
      next if row[csv_column].blank?
      
      subject = subjects[subject_code]
      next unless subject

      # Convert to float and handle invalid values
      begin
        score = row[csv_column].to_f
        next unless valid_score?(score)
      rescue ArgumentError
        next
      end

      score_data = {
        subject_id: subject.id,
        score: score
      }

      # Only add english_level if it's present and the subject is NGOAI_NGU
      if subject_code == 'NGOAI_NGU' && row['ma_ngoai_ngu'].present?
        score_data[:english_level] = row['ma_ngoai_ngu']
      end

      scores_data << score_data
    end

    [student_data, scores_data]
  end

  def bulk_insert_students(students_batch)
    return if students_batch.empty?

    Student.import(
      students_batch,
      on_duplicate_key_update: [:name],
      validate: false
    )
  end

  def bulk_insert_scores(scores_batch)
    return if scores_batch.empty?

    # Split scores into two groups: with and without english_level
    scores_with_english = scores_batch.select { |s| s[:english_level].present? }
    scores_without_english = scores_batch.reject { |s| s[:english_level].present? }

    # Bulk insert scores without english_level
    if scores_without_english.any?
      Score.import(
        scores_without_english,
        on_duplicate_key_update: [:score],
        validate: false
      )
    end

    # Bulk insert scores with english_level
    if scores_with_english.any?
      Score.import(
        scores_with_english,
        on_duplicate_key_update: [:score, :english_level],
        validate: false
      )
    end
  end

  def valid_row?(row)
    row['sbd'].present?
  end

  def valid_score?(score)
    (0..10).include?(score)
  end

  SUBJECT_MAPPING = {
    'toan' => 'TOAN',
    'ngu_van' => 'NGU_VAN',
    'ngoai_ngu' => 'NGOAI_NGU',
    'vat_li' => 'VAT_LI',
    'hoa_hoc' => 'HOA_HOC',
    'sinh_hoc' => 'SINH_HOC',
    'lich_su' => 'LICH_SU',
    'dia_li' => 'DIA_LI',
    'gdcd' => 'GDCD'
  }.freeze
end 
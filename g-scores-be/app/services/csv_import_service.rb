class CsvImportService
  BATCH_SIZE = 1000
  VALID_SCORE_RANGE = 0..10

  def initialize(file)
    @file = file
    @imported = 0
    @errors = []
    @batch = []
    @start_time = Time.current
    @logger = Rails.logger
  end

  def perform
    disable_indexes
    preload_subjects
    process_csv
    enable_indexes

    {
      imported: @imported,
      errors: @errors,
      duration: (Time.current - @start_time).round(2)
    }
  rescue => e
    @logger.error("Import failed: #{e.message}")
    enable_indexes
    raise e
  end

  private

  def disable_indexes
    @logger.info("Disabling indexes...")
    ActiveRecord::Base.connection.execute("ALTER TABLE students DISABLE TRIGGER ALL;")
    ActiveRecord::Base.connection.execute("ALTER TABLE scores DISABLE TRIGGER ALL;")
  end

  def enable_indexes
    @logger.info("Enabling indexes...")
    ActiveRecord::Base.connection.execute("ALTER TABLE students ENABLE TRIGGER ALL;")
    ActiveRecord::Base.connection.execute("ALTER TABLE scores ENABLE TRIGGER ALL;")
  end

  def preload_subjects
    @logger.info("Preloading subjects...")
    @subjects = Subject.where(code: SUBJECT_MAPPING.values).index_by(&:code)
  end

  def process_csv
    @logger.info("Starting CSV processing...")
    CSV.foreach(@file.path, headers: true) do |row|
      begin
        process_row(row)
      rescue => e
        @errors << { row: row.to_h, error: e.message }
        @logger.error("Error processing row #{row['sbd']}: #{e.message}")
      end
    end

    process_batch if @batch.any?
    @logger.info("CSV processing completed. Imported #{@imported} records with #{@errors.size} errors.")
  end

  def process_row(row)
    return unless valid_row?(row)

    student_data = {
      registration_number: row['sbd'],
      name: "Student #{row['sbd']}"
    }

    scores_data = []
    SUBJECT_MAPPING.each do |csv_column, subject_code|
      next unless row[csv_column].present?
      subject = @subjects[subject_code]
      next unless subject

      score = row[csv_column].to_f
      next unless valid_score?(score)

      score_data = {
        subject_id: subject.id,
        score: score
      }

      if subject_code == 'NGOAI_NGU' && row['ma_ngoai_ngu'].present?
        score_data[:english_level] = row['ma_ngoai_ngu']
      end

      scores_data << score_data
    end

    @batch << { student: student_data, scores: scores_data }
    @imported += 1

    if @batch.size >= BATCH_SIZE
      process_batch
      @batch = []
    end
  end

  def process_batch
    return if @batch.empty?

    @logger.info("Processing batch of #{@batch.size} records...")
    ActiveRecord::Base.transaction do
      @batch.each do |record|
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
  rescue => e
    @logger.error("Batch processing failed: #{e.message}")
    raise e
  end

  def valid_row?(row)
    return false unless row['sbd'].present?
    true
  end

  def valid_score?(score)
    VALID_SCORE_RANGE.include?(score)
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
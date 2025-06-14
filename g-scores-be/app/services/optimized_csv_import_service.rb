class OptimizedCsvImportService
  BATCH_SIZE = 10_000
  WORKER_COUNT = 4
  VALID_SCORE_RANGE = 0..10

  def initialize(file_path)
    @file_path = file_path
    @imported = 0
    @errors = []
    @start_time = Time.current
    @logger = Rails.logger
    @redis = Redis.new
    @subjects = Subject.where(code: SUBJECT_MAPPING.values).index_by(&:code)
  end

  def perform
    @logger.info("Starting optimized CSV import...")
    
    # Disable indexes and triggers
    @logger.info("Disabling indexes...")
    disable_indexes
    
    # Get total lines for progress tracking
    total_lines = `wc -l #{@file_path}`.strip.split(' ')[0].to_i - 1 # Subtract header
    @logger.info("Total lines to process: #{total_lines}")
    
    # Split file into chunks for parallel processing
    chunk_size = (total_lines / WORKER_COUNT.to_f).ceil
    @logger.info("Chunk size: #{chunk_size} lines")
    chunks = []
    
    @logger.info("Splitting file into chunks...")
    File.open(@file_path, 'r') do |file|
      header = file.gets # Read header
      
      WORKER_COUNT.times do |i|
        chunk_path = "#{@file_path}.chunk#{i}"
        @logger.info("Creating chunk #{i + 1}/#{WORKER_COUNT}: #{chunk_path}")
        
        File.open(chunk_path, 'w') do |chunk_file|
          chunk_file.puts header # Write header to each chunk
          chunk_size.times do
            line = file.gets
            break unless line
            chunk_file.puts line
          end
        end
        chunks << chunk_path
      end
    end

    # Process chunks in parallel using Sidekiq
    @logger.info("Enqueueing chunk processing jobs...")
    chunks.each do |chunk_path|
      CsvChunkProcessorWorker.perform_async(chunk_path)
    end

    # Wait for all chunks to be processed
    @logger.info("Waiting for chunks to be processed...")
    while @redis.get('csv_import_completed_chunks').to_i < WORKER_COUNT
      sleep(1)
      completed = @redis.get('csv_import_completed_chunks').to_i
      @logger.info("Progress: #{completed}/#{WORKER_COUNT} chunks completed")
    end

    # Enable indexes and triggers
    @logger.info("Enabling indexes...")
    enable_indexes

    {
      imported: @imported,
      errors: @errors,
      duration: (Time.current - @start_time).round(2)
    }
  rescue => e
    @logger.error("Import failed: #{e.message}")
    @logger.error(e.backtrace.join("\n"))
    enable_indexes
    raise e
  ensure
    # Cleanup chunk files
    @logger.info("Cleaning up chunk files...")
    chunks.each { |chunk| File.delete(chunk) if File.exist?(chunk) }
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
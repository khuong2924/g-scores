class CsvImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'csv_import', retry: 3

  def perform(file_path)
    Rails.logger.info("Starting CSV import job for file: #{file_path}")
    
    begin
      # Check if file exists
      unless File.exist?(file_path)
        Rails.logger.error("File not found: #{file_path}")
        raise "File not found: #{file_path}"
      end

      # Log file size
      file_size = File.size(file_path)
      Rails.logger.info("File size: #{file_size} bytes")

      # Start import process
      Rails.logger.info("Initializing OptimizedCsvImportService...")
      result = OptimizedCsvImportService.new(file_path).perform

      # Get errors from Redis
      Rails.logger.info("Retrieving errors from Redis...")
      redis = Redis.new
      errors = []
      while (error_json = redis.lpop('csv_import_errors'))
        errors.concat(JSON.parse(error_json))
      end

      # Log results
      Rails.logger.info("Import completed:")
      Rails.logger.info("- Total records imported: #{result[:imported]}")
      Rails.logger.info("- Number of errors: #{errors.size}")
      Rails.logger.info("- Duration: #{result[:duration]} seconds")

      # Send email notification to admin
      Rails.logger.info("Sending email notification...")
      ImportMailer.import_completed(
        ENV['ADMIN_EMAIL'] || 'admin@example.com',
        {
          imported: result[:imported],
          errors: errors,
          duration: result[:duration]
        }
      ).deliver_later

      Rails.logger.info("CSV import process completed successfully")
    rescue => e
      Rails.logger.error("CSV import failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    ensure
      # Clean up temporary file
      if File.exist?(file_path)
        Rails.logger.info("Cleaning up temporary file: #{file_path}")
        File.delete(file_path)
      end
    end
  end
end 
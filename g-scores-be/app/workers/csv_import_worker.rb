class CsvImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'csv_import', retry: 3

  def perform(file_path)
    Rails.logger.info("Starting CSV import job for file: #{file_path}")
    
    begin
      result = CsvImportService.new(File.open(file_path)).perform
      Rails.logger.info("CSV import completed successfully. Imported #{result[:imported]} records with #{result[:errors].size} errors.")
    rescue => e
      Rails.logger.error("CSV import failed: #{e.message}")
      raise e
    ensure
      # Clean up temporary file
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end 
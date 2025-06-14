class RawScoreImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'csv_import', retry: 3

  def perform(chunk_path)
    Rails.logger.info("Processing chunk: #{chunk_path}")
    
    begin
      RawScore.import_in_chunks(chunk_path)
      
      # Update progress in Redis
      redis = Redis.new
      redis.incr('csv_import_completed_chunks')
      
    rescue => e
      Rails.logger.error("Chunk processing failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    ensure
      # Cleanup chunk file
      File.delete(chunk_path) if File.exist?(chunk_path)
    end
  end
end 
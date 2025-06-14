class RawScoreImportService
  CHUNK_SIZE = 10_000

  def self.process(file_path)
    require 'csv'
    
    # Create temp directory if it doesn't exist
    temp_dir = Rails.root.join('tmp', 'csv_imports')
    FileUtils.mkdir_p(temp_dir)
    
    # Reset progress counter
    redis = Redis.new
    redis.del('csv_import_completed_chunks')
    
    # Count total rows
    total_rows = `wc -l "#{file_path}"`.strip.split(' ')[0].to_i - 1 # Subtract header row
    total_chunks = (total_rows.to_f / CHUNK_SIZE).ceil
    
    # Split CSV into chunks
    chunk_paths = []
    current_chunk = []
    current_chunk_number = 0
    
    CSV.foreach(file_path, headers: true) do |row|
      current_chunk << row
      
      if current_chunk.size >= CHUNK_SIZE
        chunk_path = write_chunk_to_file(current_chunk, temp_dir, current_chunk_number)
        chunk_paths << chunk_path
        current_chunk = []
        current_chunk_number += 1
      end
    end
    
    # Write remaining rows
    if current_chunk.any?
      chunk_path = write_chunk_to_file(current_chunk, temp_dir, current_chunk_number)
      chunk_paths << chunk_path
    end
    
    # Queue chunks for processing
    chunk_paths.each do |chunk_path|
      RawScoreImportWorker.perform_async(chunk_path)
    end
    
    # Return total chunks for progress tracking
    chunk_paths.size
  end
  
  private
  
  def self.write_chunk_to_file(chunk, temp_dir, chunk_number)
    chunk_path = File.join(temp_dir, "chunk_#{chunk_number}.csv")
    
    CSV.open(chunk_path, 'w') do |csv|
      # Write headers
      csv << chunk.first.headers if chunk.first
      
      # Write rows
      chunk.each do |row|
        csv << row
      end
    end
    
    chunk_path
  end
end 
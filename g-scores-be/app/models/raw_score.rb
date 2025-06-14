class RawScore < ApplicationRecord
  validates :registration_number, presence: true, uniqueness: true
  validates :toan, :ngu_van, :ngoai_ngu, :vat_li, :hoa_hoc, :sinh_hoc, :lich_su, :dia_li, :gdcd,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10, allow_nil: true }

  # Constants for score levels
  SCORE_LEVELS = {
    excellent: 8.0,    # >= 8.0
    good: 6.0,         # >= 6.0 and < 8.0
    average: 4.0,      # >= 4.0 and < 6.0
    poor: 0.0          # < 4.0
  }

  def self.score_distribution_by_subject(subject_column)
    result = {
      excellent: where("#{subject_column} >= ?", 8.0).where.not("#{subject_column}": nil).count,
      good: where("#{subject_column} >= ? AND #{subject_column} < ?", 6.0, 8.0).count,
      average: where("#{subject_column} >= ? AND #{subject_column} < ?", 4.0, 6.0).count,
      poor: where("#{subject_column} < ?", 4.0).where.not("#{subject_column}": nil).count
    }
    
    result
  end

  def self.top_students_group_a(limit: 10)
    select('registration_number, name, toan, vat_li, hoa_hoc')
      .where('toan > 0 AND vat_li > 0 AND hoa_hoc > 0')
      .order(Arel.sql('((CAST(toan AS FLOAT) + CAST(vat_li AS FLOAT) + CAST(hoa_hoc AS FLOAT)) / 3.0) DESC'))
      .limit(limit)
      .map do |student|
        toan = student.toan.to_f
        vat_li = student.vat_li.to_f
        hoa_hoc = student.hoa_hoc.to_f
        
        average_score = ((toan + vat_li + hoa_hoc) / 3.0).round(2)

        {
          registration_number: student.registration_number,
          name: student.name || "Học sinh #{student.registration_number}",
          scores: {
            toan: toan,
            vat_li: vat_li,
            hoa_hoc: hoa_hoc
          },
          average_score: average_score
        }
      end
  end

  def self.import_from_csv(file_path)
    require 'csv'
    
    # Disable indexes for faster import
    connection.execute('ALTER TABLE raw_scores DISABLE TRIGGER ALL')
    
    begin
      CSV.foreach(file_path, headers: true) do |row|
        create!(
          registration_number: row['sbd'],
          name: row['ho_ten'],
          toan: row['toan'],
          ngu_van: row['ngu_van'],
          ngoai_ngu: row['ngoai_ngu'],
          ma_ngoai_ngu: row['ma_ngoai_ngu'],
          vat_li: row['vat_li'],
          hoa_hoc: row['hoa_hoc'],
          sinh_hoc: row['sinh_hoc'],
          lich_su: row['lich_su'],
          dia_li: row['dia_li'],
          gdcd: row['gdcd']
        )
      end
    ensure
      # Re-enable indexes
      connection.execute('ALTER TABLE raw_scores ENABLE TRIGGER ALL')
    end
  end

  def self.import_in_chunks(file_path, chunk_size: 10_000)
    require 'csv'
    
    # Disable indexes for faster import
    connection.execute('ALTER TABLE raw_scores DISABLE TRIGGER ALL')
    
    begin
      chunk = []
      CSV.foreach(file_path, headers: true) do |row|
        chunk << {
          registration_number: row['sbd'],
          name: row['ho_ten'],
          toan: row['toan'],
          ngu_van: row['ngu_van'],
          ngoai_ngu: row['ngoai_ngu'],
          ma_ngoai_ngu: row['ma_ngoai_ngu'],
          vat_li: row['vat_li'],
          hoa_hoc: row['hoa_hoc'],
          sinh_hoc: row['sinh_hoc'],
          lich_su: row['lich_su'],
          dia_li: row['dia_li'],
          gdcd: row['gdcd'],
          created_at: Time.current,
          updated_at: Time.current
        }

        if chunk.size >= chunk_size
          import(chunk, on_duplicate_key_update: [:name, :toan, :ngu_van, :ngoai_ngu, :ma_ngoai_ngu, 
                                                 :vat_li, :hoa_hoc, :sinh_hoc, :lich_su, :dia_li, :gdcd])
          chunk = []
        end
      end

      # Import remaining records
      import(chunk, on_duplicate_key_update: [:name, :toan, :ngu_van, :ngoai_ngu, :ma_ngoai_ngu, 
                                             :vat_li, :hoa_hoc, :sinh_hoc, :lich_su, :dia_li, :gdcd]) if chunk.any?
    ensure
      # Re-enable indexes
      connection.execute('ALTER TABLE raw_scores ENABLE TRIGGER ALL')
    end
  end
end 
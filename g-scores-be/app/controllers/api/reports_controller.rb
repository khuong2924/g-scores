class Api::ReportsController < ApplicationController
    def score_distribution
      result = {}
      
      # Map subject codes to column names
      subject_mapping = {
        'TOAN' => 'toan',
        'NGU_VAN' => 'ngu_van',
        'NGOAI_NGU' => 'ngoai_ngu',
        'VAT_LI' => 'vat_li',
        'HOA_HOC' => 'hoa_hoc',
        'SINH_HOC' => 'sinh_hoc',
        'LICH_SU' => 'lich_su',
        'DIA_LI' => 'dia_li',
        'GDCD' => 'gdcd'
      }

      subject_mapping.each do |subject_code, column_name|
        result[subject_code] = {
          '>=8' => RawScore.where("#{column_name} >= ?", 8).where.not("#{column_name}": nil).count,
          '6-8' => RawScore.where("#{column_name} >= ? AND #{column_name} < ?", 6, 8).count,
          '4-6' => RawScore.where("#{column_name} >= ? AND #{column_name} < ?", 4, 6).count,
          '<4' => RawScore.where("#{column_name} < ?", 4).where.not("#{column_name}": nil).count
        }
      end

      render json: result
    end
  end
require 'csv'

# Create subjects
subjects = [
  { name: 'Toán', code: 'TOAN' },
  { name: 'Ngữ Văn', code: 'NGU_VAN' },
  { name: 'Ngoại Ngữ', code: 'NGOAI_NGU' },
  { name: 'Vật Lý', code: 'VAT_LI' },
  { name: 'Hóa Học', code: 'HOA_HOC' },
  { name: 'Sinh Học', code: 'SINH_HOC' },
  { name: 'Lịch Sử', code: 'LICH_SU' },
  { name: 'Địa Lý', code: 'DIA_LI' },
  { name: 'GDCD', code: 'GDCD' }
]

subjects.each do |subject|
  Subject.find_or_create_by!(code: subject[:code]) do |s|
    s.name = subject[:name]
  end
end

# Read and import CSV data
csv_file = Rails.root.join('db', 'diem_thi_thpt_2024.csv')
return unless File.exist?(csv_file)

CSV.foreach(csv_file, headers: true) do |row|
  student = Student.create!(registration_number: row['sbd'])

  # Map CSV columns to subject codes
  subject_mapping = {
    'toan' => 'TOAN',
    'ngu_van' => 'NGU_VAN',
    'vat_li' => 'VAT_LI',
    'hoa_hoc' => 'HOA_HOC',
    'sinh_hoc' => 'SINH_HOC',
    'lich_su' => 'LICH_SU',
    'dia_li' => 'DIA_LI',
    'gdcd' => 'GDCD',
    'ngoai_ngu' => 'NGOAI_NGU'
  }

  subject_mapping.each do |csv_column, subject_code|
    score = row[csv_column]
    next if score.blank?

    subject = Subject.find_by!(code: subject_code)
    Score.create!(
      student: student,
      subject: subject,
      score: score.to_f
    )
  end
end

puts "Imported #{Student.count} students"
puts "Imported #{Score.count} scores"
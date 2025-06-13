require 'csv'

CSV.foreach('db/diem_thi_thpt_2024.csv', headers: true) do |row|
  student = Student.find_or_create_by!(
    registration_number: row['registration_number'],
    name: row['name']
  )

  %w[math physics chemistry].each do |subject_code|
    subject = Subject.find_or_create_by!(
      code: subject_code.upcase,
      name: subject_code.capitalize
    )

    Score.create!(
      student: student,
      subject: subject,
      score: row["#{subject_code}_score"].to_f
    )
  end
end
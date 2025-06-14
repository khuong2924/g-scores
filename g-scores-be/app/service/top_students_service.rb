class TopStudentsService
    def block_a
      block_a_subjects = Subject.where(code: %w[TOAN VAT_LI HOA_HOC]).pluck(:id)
      
      students = Student.joins(:scores)
        .where(scores: { subject_id: block_a_subjects })
        .group('students.id')
        .having('COUNT(DISTINCT scores.subject_id) = 3')
        .select('students.*, AVG(scores.score) as average_score')
        .order('average_score DESC')
        .limit(10)
      
      students.map do |student|
        {
          registration_number: student.registration_number,
          name: student.name,
          average_score: student.average_score.round(2),
          scores: {
            toan: student.scores.find_by(subject_id: block_a_subjects[0])&.score,
            vat_li: student.scores.find_by(subject_id: block_a_subjects[1])&.score,
            hoa_hoc: student.scores.find_by(subject_id: block_a_subjects[2])&.score
          }
        }
      end
    end
  end
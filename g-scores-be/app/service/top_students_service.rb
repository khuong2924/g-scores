class TopStudentsService
    def block_a
      block_a_subjects = Subject.where(code: %w[MATH PHYS CHEM]).pluck(:id)
      
      students = Student.joins(:scores)
        .where(scores: { subject_id: block_a_subjects })
        .group('students.id')
        .select('students.*, SUM(scores.score) as total_score')
        .order('total_score DESC')
        .limit(10)
      
      students.map do |student|
        {
          registration_number: student.registration_number,
          name: student.name,
          total_score: student.total_score
        }
      end
    end
  end
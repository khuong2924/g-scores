class ReportService
    def score_distribution
      subjects = Subject.all
      result = {}
  
      subjects.each do |subject|
        result[subject.name] = {
          '>=8' => Score.where(subject: subject).where('score >= ?', 8).count,
          '6-8' => Score.where(subject: subject).where('score >= ? AND score < ?', 6, 8).count,
          '4-6' => Score.where(subject: subject).where('score >= ? AND score < ?', 4, 6).count,
          '<4' => Score.where(subject: subject).where('score < ?', 4).count
        }
      end
  
      result
    end
  end
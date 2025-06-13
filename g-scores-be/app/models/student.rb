class Student < ApplicationRecord
    has_many :scores, dependent: :destroy
    has_many :subjects, through: :scores
  
    validates :registration_number, presence: true, uniqueness: true

    # Constants for score levels
    SCORE_LEVELS = {
      excellent: 8.0,    # >= 8.0
      good: 6.0,         # >= 6.0 and < 8.0
      average: 4.0,      # >= 4.0 and < 6.0
      poor: 0.0          # < 4.0
    }

    # Get score for a specific subject
    def get_score(subject_code)
      scores.joins(:subject).find_by(subjects: { code: subject_code.upcase })&.score
    end

    # Calculate group A score (math + physics + chemistry)
    def group_a_score
      math = get_score('TOAN')
      physics = get_score('VAT_LI')
      chemistry = get_score('HOA_HOC')
      
      return nil if [math, physics, chemistry].any?(&:nil?)
      (math + physics + chemistry) / 3.0
    end

    # Get score level for a specific subject
    def score_level(subject_code)
      score = get_score(subject_code)
      return nil if score.nil?

      case score
      when SCORE_LEVELS[:excellent]..Float::INFINITY
        :excellent
      when SCORE_LEVELS[:good]...SCORE_LEVELS[:excellent]
        :good
      when SCORE_LEVELS[:average]...SCORE_LEVELS[:good]
        :average
      else
        :poor
      end
    end

    # Class methods for statistics
    def self.score_distribution_by_subject(subject_code)
      levels = SCORE_LEVELS.keys
      result = {}
      
      levels.each do |level|
        min_score = SCORE_LEVELS[level]
        max_score = level == :excellent ? Float::INFINITY : SCORE_LEVELS[levels[levels.index(level) + 1]]
        
        count = joins(:scores)
                .joins(:subjects)
                .where(subjects: { code: subject_code.upcase })
                .where(scores: { score: min_score...max_score })
                .count
        
        result[level] = count
      end
      
      result
    end

    def self.top_students_group_a(limit = 10)
      joins(:scores)
        .joins(:subjects)
        .where(subjects: { code: ['TOAN', 'VAT_LI', 'HOA_HOC'] })
        .group('students.id')
        .having('COUNT(DISTINCT subjects.code) = 3')
        .order('AVG(scores.score) DESC')
        .limit(limit)
    end
end
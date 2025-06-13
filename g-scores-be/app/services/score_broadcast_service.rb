class ScoreBroadcastService
  BATCH_SIZE = 100

  def self.broadcast_score_update(score)
    # Sử dụng Redis pipeline để giảm số lần gọi Redis
    ActionCable.server.broadcast(
      "scores",
      {
        type: "score_update",
        data: {
          student_id: score.student_id,
          subject_id: score.subject_id,
          score: score.score,
          updated_at: score.updated_at
        }
      }
    )

    # Broadcast to specific student's channel
    ActionCable.server.broadcast(
      "student_#{score.student.registration_number}_scores",
      {
        type: "score_update",
        data: {
          subject_id: score.subject_id,
          score: score.score,
          updated_at: score.updated_at
        }
      }
    )
  end

  def self.broadcast_batch_update(student_id, scores)
    # Chia nhỏ batch để tránh quá tải
    scores.each_slice(BATCH_SIZE) do |batch_scores|
      ActionCable.server.broadcast(
        "scores",
        {
          type: "batch_score_update",
          data: {
            student_id: student_id,
            scores: batch_scores.map { |score| {
              subject_id: score.subject_id,
              score: score.score,
              updated_at: score.updated_at
            }}
          }
        }
      )
    end
  end

  # Thêm method để broadcast thống kê
  def self.broadcast_statistics
    ActionCable.server.broadcast(
      "scores",
      {
        type: "statistics_update",
        data: {
          timestamp: Time.current,
          statistics: {
            total_students: Student.count,
            total_scores: Score.count,
            average_score: Score.average(:score)&.round(2)
          }
        }
      }
    )
  end
end 
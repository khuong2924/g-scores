class Score < ApplicationRecord
  belongs_to :student
  belongs_to :subject

  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  after_commit :broadcast_update

  private

  def broadcast_update
    ScoreBroadcastService.broadcast_score_update(self)
  end
end
class Subject < ApplicationRecord
    has_many :scores, dependent: :destroy
    has_many :students, through: :scores
  
    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
  end
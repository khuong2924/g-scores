class Student < ApplicationRecord
    has_many :scores, dependent: :destroy
    has_many :subjects, through: :scores
  
    validates :registration_number, presence: true, uniqueness: true
  end
class CreateScores < ActiveRecord::Migration[7.0]
  def change
    create_table :scores do |t|
      t.references :student, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.float :score, null: false
      t.string :english_level

      t.timestamps
    end

    add_index :scores, [:student_id, :subject_id], unique: true
  end
end

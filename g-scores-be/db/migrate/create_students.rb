class CreateStudents < ActiveRecord::Migration[7.0]
    def change
      create_table :students do |t|
        t.string :registration_number, null: false, index: { unique: true }
        t.string :name
        t.timestamps
      end
    end
  end
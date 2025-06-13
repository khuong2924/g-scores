class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :registration_number
      t.string :name

      t.timestamps
    end
    add_index :students, :registration_number, unique: true
  end
end

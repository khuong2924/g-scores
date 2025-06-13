class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.string :code, null: false
      t.string :name

      t.timestamps
    end
    add_index :subjects, :code, unique: true
  end
end

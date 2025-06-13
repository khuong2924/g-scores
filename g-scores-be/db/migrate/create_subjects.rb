class CreateSubjects < ActiveRecord::Migration[7.0]
    def change
      create_table :subjects do |t|
        t.string :name, null: false
        t.string :code, null: false, index: { unique: true }
        t.timestamps
      end
    end
  end
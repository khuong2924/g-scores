class CreateRawScores < ActiveRecord::Migration[7.0]
  def change
    create_table :raw_scores do |t|
      t.string :registration_number, null: false
      t.string :name
      t.decimal :toan, precision: 4, scale: 2
      t.decimal :ngu_van, precision: 4, scale: 2
      t.decimal :ngoai_ngu, precision: 4, scale: 2
      t.string :ma_ngoai_ngu
      t.decimal :vat_li, precision: 4, scale: 2
      t.decimal :hoa_hoc, precision: 4, scale: 2
      t.decimal :sinh_hoc, precision: 4, scale: 2
      t.decimal :lich_su, precision: 4, scale: 2
      t.decimal :dia_li, precision: 4, scale: 2
      t.decimal :gdcd, precision: 4, scale: 2

      t.timestamps
    end

    add_index :raw_scores, :registration_number, unique: true
  end
end 
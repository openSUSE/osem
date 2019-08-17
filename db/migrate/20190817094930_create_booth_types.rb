class CreateBoothTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :booth_types do |t|
      t.references :program
      t.string :title, null: false
      t.string :description

      t.timestamps
    end
    add_reference :booths, :booth_type, index: true
  end
end

class CreateBoothGroup < ActiveRecord::Migration[5.2]
  def change
    create_table :booth_groups do |t|
      t.references :program
      t.string :name, null: false

      t.timestamps
    end
    add_reference :booths, :booth_group, index: true
  end
end

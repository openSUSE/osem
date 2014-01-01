class CreateVdays < ActiveRecord::Migration
  def up
    create_table :vdays do |t|
      t.references :conference
      t.date :day
      t.text :description

      t.timestamps
    end
  end

  def down
    drop_table :vdays
  end
end

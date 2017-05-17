class CreateCallForBooths < ActiveRecord::Migration
  def change
    create_table :call_for_booths do |t|
      t.date :start_date
      t.date :end_date
      t.integer :booth_limit

      t.timestamps null: false
    end
  end
end

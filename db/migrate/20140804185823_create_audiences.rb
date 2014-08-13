class CreateAudiences < ActiveRecord::Migration
  def change
    create_table :audiences do |t|
      t.integer :conference_id
      t.date :registration_start_date
      t.date :registration_end_date
      t.text :registration_description

      t.timestamps
    end
  end
end

class CreateInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :invites do |t|
      t.integer :conference_id
      t.integer :user_id
      t.date :end_date
      t.text :invite_for

      t.timestamps
    end
  end
end

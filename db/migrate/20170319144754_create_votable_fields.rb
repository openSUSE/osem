class CreateVotableFields < ActiveRecord::Migration
  def change
    create_table :votable_fields do |t|
      t.string :title
      t.string :votable_type
      t.boolean :enabled, default: true
      t.references :conference

      t.timestamps null: false
    end
  end
end

class CreateTrackTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :track_types do |t|
      t.references :program
      t.string :title, null: false
      t.string :description

      t.timestamps
    end
  end
end

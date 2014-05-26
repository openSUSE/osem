class CreateSponsorshipLevels < ActiveRecord::Migration
  def change
    create_table :sponsorship_levels do |t|
      t.string :title
      t.text :description
      t.belongs_to :conference
      t.timestamps
    end
  end
end

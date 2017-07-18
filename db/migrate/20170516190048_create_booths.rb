class CreateBooths < ActiveRecord::Migration
  def change
    create_table :booths do |t|
      t.string :title
      t.text :description
      t.text :reasoning
      t.string :state
      t.string :logo_link
      t.string :website_url
      t.text :submitter_relationship
      t.references :conference

      t.timestamps null: false
    end
  end
end

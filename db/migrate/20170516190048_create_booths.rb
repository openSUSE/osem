# frozen_string_literal: true

class CreateBooths < ActiveRecord::Migration[4.2]
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

# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :social_tag
      t.string :email
      t.string :facebook
      t.string :googleplus
      t.string :twitter
      t.string :instagram

      t.boolean :public
      t.integer :conference_id

      t.timestamps
    end
  end
end

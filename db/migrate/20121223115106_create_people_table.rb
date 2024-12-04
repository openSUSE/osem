# frozen_string_literal: true

class CreatePeopleTable < ActiveRecord::Migration[5.0]
  def up
    create_table :people do |t|
      t.string :guid, null: false
      t.string :first_name, default: ''
      t.string :last_name, default: ''
      t.string :public_name, default: ''
      t.string :company, default: ''
      t.string :email, null: false
      t.boolean :email_public
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.text :biography
      t.references :user
      t.timestamps
    end
  end

  def down
    drop_table :people
  end
end

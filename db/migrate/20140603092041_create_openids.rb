# frozen_string_literal: true

class CreateOpenids < ActiveRecord::Migration
  def change
    create_table :openids do |t|
      t.string :provider
      t.string :email
      t.string :uid
      t.integer :user_id

      t.timestamps
    end
  end
end

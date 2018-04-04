# frozen_string_literal: true

class CreateVotes < ActiveRecord::Migration
  def up
    create_table :votes do |t|
      t.references :person
      t.references :event
      t.integer :rating

      t.timestamps
    end
  end

  def down
    drop_table :votes
  end
end

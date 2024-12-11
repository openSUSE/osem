# frozen_string_literal: true

class DropPersonAndEventPersonTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :people
    drop_table :event_people
  end
end

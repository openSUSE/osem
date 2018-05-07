# frozen_string_literal: true

class CreateTableSupporterRegistrations < ActiveRecord::Migration
  def up
    create_table :supporter_registrations do |t|
      t.references :registration
      t.references :supporter_level
      t.references :conference
      t.string :name
      t.string :email
      t.string :code
      t.boolean :code_is_valid, default: false
    end
  end

  def down
    drop_table :supporter_registrations
  end
end

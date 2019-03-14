# frozen_string_literal: true

class CreateAhoyEvents < ActiveRecord::Migration
  def change
    adapter_type = connection.adapter_name.downcase.to_sym

    create_table :ahoy_events  do |t|
      case adapter_type
      when :postgresql
        t.uuid :visit_id
      else
        t.integer :visit_id
      end

      # user
      t.integer :user_id
      # add t.string :user_type if polymorphic
      t.string :name
      t.text :properties
      t.timestamp :time
    end

    add_index :ahoy_events, :visit_id
    add_index :ahoy_events, :user_id
    add_index :ahoy_events, :time
  end
end

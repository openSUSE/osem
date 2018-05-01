# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :conference
      t.timestamps
    end
  end
end

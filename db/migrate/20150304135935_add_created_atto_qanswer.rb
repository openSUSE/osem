# frozen_string_literal: true

class AddCreatedAttoQanswer < ActiveRecord::Migration
  def change
    add_column :qanswers, :created_at, :datetime
    add_column :qanswers, :updated_at, :datetime
  end
end

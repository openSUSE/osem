# frozen_string_literal: true

class AddIsDisabledFlagToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_disabled, :boolean, default: false
  end
end

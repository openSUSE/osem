# frozen_string_literal: true

class SetRoomPublicDefaultToFalse < ActiveRecord::Migration
  def change
    change_column :rooms, :public, :boolean, default: false
  end
end

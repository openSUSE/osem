# frozen_string_literal: true

class UseVdaysVpositionsDefaults < ActiveRecord::Migration
  def up
    change_column :conferences, :use_vpositions, :boolean, default: false
    change_column :conferences, :use_vdays, :boolean, default: false
  end

  def down
    change_column :conferences, :use_vpositions, :boolean, default: nil
    change_column :conferences, :use_vdays, :boolean, default: nil
  end
end

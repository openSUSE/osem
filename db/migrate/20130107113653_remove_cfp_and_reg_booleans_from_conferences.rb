# frozen_string_literal: true

class RemoveCfpAndRegBooleansFromConferences < ActiveRecord::Migration
  def up
    remove_column :conferences, :cfp_open
    remove_column :conferences, :registration_open
  end

  def down
    add_column :conferences, :cfp_open, default: false
    add_column :registration_open, default: false
  end
end

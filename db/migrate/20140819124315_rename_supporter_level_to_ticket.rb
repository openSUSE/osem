# frozen_string_literal: true

class RenameSupporterLevelToTicket < ActiveRecord::Migration
  def up
    rename_table :supporter_levels, :tickets
  end

  def down
    rename_table :tickets, :supporter_levels
  end
end

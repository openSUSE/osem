# frozen_string_literal: true

class RenameSupporterLevelToTicket < ActiveRecord::Migration[4.2]
  def up
    rename_table :supporter_levels, :tickets
  end

  def down
    rename_table :tickets, :supporter_levels
  end
end

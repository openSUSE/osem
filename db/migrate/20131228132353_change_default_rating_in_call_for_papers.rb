# frozen_string_literal: true

class ChangeDefaultRatingInCallForPapers < ActiveRecord::Migration
  def up
    change_column :call_for_papers, :rating, :integer, default: 3
  end

  def down
    change_column :call_for_papers, :rating, :integer, null: 1
  end
end

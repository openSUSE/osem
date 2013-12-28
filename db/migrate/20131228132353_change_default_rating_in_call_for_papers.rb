class ChangeDefaultRatingInCallForPapers < ActiveRecord::Migration
  def up
    change_column :call_for_papers, :rating, :integer, :default => 3
  end

  def down
  end
end

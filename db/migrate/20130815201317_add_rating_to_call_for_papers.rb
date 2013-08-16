class AddRatingToCallForPapers < ActiveRecord::Migration
  def change
    add_column :call_for_papers, :rating, :integer
  end
end

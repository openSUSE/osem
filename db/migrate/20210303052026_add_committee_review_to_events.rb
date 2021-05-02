class AddCommitteeReviewToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :committee_review, :text
  end
end

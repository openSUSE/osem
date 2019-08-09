class AddPolymorphicToVote < ActiveRecord::Migration[5.2]
  def change
    add_column :votes, :votable_type, :string
    add_column :votes, :votable_id, :integer
  end
end

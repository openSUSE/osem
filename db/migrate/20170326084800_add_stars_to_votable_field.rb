class AddStarsToVotableField < ActiveRecord::Migration
  def change
    add_column :votable_fields, :stars, :integer, default: 5
  end
end

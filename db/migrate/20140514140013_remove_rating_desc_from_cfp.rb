# frozen_string_literal: true

class RemoveRatingDescFromCfp < ActiveRecord::Migration
  def up
    remove_column :call_for_papers, :rating_desc
  end

  def down
    add_column :call_for_papers, :rating_desc, :text
  end
end

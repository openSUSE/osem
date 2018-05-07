# frozen_string_literal: true

class AddRatingDescToCallForPapers < ActiveRecord::Migration
  def change
    add_column :call_for_papers, :rating_desc, :text
  end
end

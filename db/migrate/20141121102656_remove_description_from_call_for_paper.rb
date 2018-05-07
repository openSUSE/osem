# frozen_string_literal: true

class RemoveDescriptionFromCallForPaper < ActiveRecord::Migration
  def change
    remove_column :call_for_papers, :description, :text
  end
end

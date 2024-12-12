# frozen_string_literal: true

class AddBlindVotingToPrograms < ActiveRecord::Migration[4.2]
  def change
    add_column :programs, :blind_voting, :boolean, default: false
  end
end

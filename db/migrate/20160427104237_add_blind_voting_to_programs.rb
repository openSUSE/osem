# frozen_string_literal: true

class AddBlindVotingToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :blind_voting, :boolean, default: false
  end
end

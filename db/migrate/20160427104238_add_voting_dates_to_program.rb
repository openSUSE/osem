# frozen_string_literal: true

class AddVotingDatesToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :voting_start_date, :datetime
    add_column :programs, :voting_end_date, :datetime
  end
end

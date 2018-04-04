# frozen_string_literal: true

class CreateSponsorshipLevels < ActiveRecord::Migration
  def change
    create_table :sponsorship_levels do |t|
      t.string :title
      t.belongs_to :conference
      t.timestamps
    end
  end
end

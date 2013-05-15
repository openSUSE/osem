class DropAdditionalSpeakers < ActiveRecord::Migration
  def up
    remove_column :registrations, :additional_speakers
  end

  def down
    add_column :registrations, :additional_speakers
  end
end

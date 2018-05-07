# frozen_string_literal: true

class RenameAttendingSocialEventsWithPartner < ActiveRecord::Migration
  def up
    rename_column :registrations, :attending_social_events_with_partner, :attending_with_partner
  end

  def down
  end
end

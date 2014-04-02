class AddSchedulePublicToCallForPapers < ActiveRecord::Migration
  def change
    add_column :call_for_papers, :schedule_public, :boolean
  end
end

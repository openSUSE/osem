class AddSubmissionInstructionsToEventTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :event_types, :submission_instructions, :text
  end
end

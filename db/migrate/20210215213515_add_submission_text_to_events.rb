class AddSubmissionTextToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :submission_text, :text
  end
end

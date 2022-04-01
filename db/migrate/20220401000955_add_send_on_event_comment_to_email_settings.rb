class AddSendOnEventCommentToEmailSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :email_settings, :send_on_event_comment, :boolean, default: true
  end
end

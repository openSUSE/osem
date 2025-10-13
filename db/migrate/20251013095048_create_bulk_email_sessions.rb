class CreateBulkEmailSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_email_sessions do |t|
      t.string :token, null: false
      t.text :recipient_emails
      t.string :filter_type
      t.string :search_term
      t.datetime :expires_at

      t.timestamps
    end
    add_index :bulk_email_sessions, :token, unique: true
    add_index :bulk_email_sessions, :expires_at
  end
end
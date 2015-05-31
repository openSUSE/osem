class FixColumnNames < ActiveRecord::Migration
  def up
    change_table :email_settings do |t|
      t.rename :registration_email_template, :registration_body
      t.rename :accepted_email_template, :accepted_body
	t.rename :rejected_email_template, :rejected_body
	t.rename :confirmed_email_template, :confirmed_body
    end
  end

  def down
    change_table :email_settings do |t|
      t.rename :registration_body, :registration_email_template
      t.rename :accepted_body, :accepted_email_template
	t.rename :rejected_body, :rejected_email_template
	t.rename :confirmed_body, :confirmed_email_template
    end
  end
end

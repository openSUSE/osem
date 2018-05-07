# frozen_string_literal: true

class CreateEmailTable < ActiveRecord::Migration
  def up
    create_table :email_settings do |t|
      t.references :conference
      t.boolean :send_on_registration, default: true
      t.boolean :send_on_accepted, default: true
      t.boolean :send_on_rejected, default: true
      t.boolean :send_on_confirmed_without_registration, default: true
      t.text :registration_email_template
      t.text :accepted_email_template
      t.text :rejected_email_template
      t.text :confirmed_email_template
      t.timestamps
    end
  end

  def down
    drop_table :email_settings
  end
end

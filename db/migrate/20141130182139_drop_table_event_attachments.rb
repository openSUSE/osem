# frozen_string_literal: true

class DropTableEventAttachments < ActiveRecord::Migration[4.2]
  def change
    drop_table :event_attachments
  end
end

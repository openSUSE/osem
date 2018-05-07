# frozen_string_literal: true

class DropTableEventAttachments < ActiveRecord::Migration
  def change
    drop_table :event_attachments
  end
end

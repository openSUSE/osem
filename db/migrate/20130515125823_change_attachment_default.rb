class ChangeAttachmentDefault < ActiveRecord::Migration
  def up
    change_column_default(:event_attachments, :public, :default => true)
  end
  def down
    change_column_default(:event_attachments, :public, :default => nil)
  end
end

class ChangeCommentSubjectLimit < ActiveRecord::Migration[7.0]
  def up
    change_column :comments, :subject, :string, limit: 255
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('Cannot reverse migration.')
  end
end

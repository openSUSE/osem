class UserEmailPublicDefaultsToFalse < ActiveRecord::Migration[5.0]
  def up
    change_column_default :users, :email_public, false
  end

  def down
    change_column_default :users, :email_public, true
  end
end

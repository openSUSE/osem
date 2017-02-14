class ChangeEmailPublicFromUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :email_public, true
  end
end

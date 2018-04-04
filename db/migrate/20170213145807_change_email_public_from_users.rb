# frozen_string_literal: true

class ChangeEmailPublicFromUsers < ActiveRecord::Migration
  def up
    change_column_default :users, :email_public, true
  end

  def down
    change_column_default :users, :email_public, nil
  end
end

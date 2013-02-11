class AddIrcNickToPeopleTable < ActiveRecord::Migration
  def change
    add_column :people, :irc_nickname, :string
  end
end

# frozen_string_literal: true

class AddIrcNickToPeopleTable < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :irc_nickname, :string
  end
end

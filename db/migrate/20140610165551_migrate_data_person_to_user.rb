# frozen_string_literal: true

class MigrateDataPersonToUser < ActiveRecord::Migration
  class TempPerson < ActiveRecord::Base
    self.table_name = 'people'
  end

  class TempUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  def change
    TempPerson.all.each do |p|
      user = TempUser.find_by(id: p.user_id)
      next unless user

      if p.public_name.empty?
        user.name = p.email
      else
        user.name = p.public_name
      end
      user.biography = p.biography
      user.nickname = p.irc_nickname
      user.affiliation = p.company
      user.avatar_file_name = p.avatar_file_name
      user.avatar_content_type = p.avatar_content_type
      user.avatar_file_size = p.avatar_file_size
      user.avatar_updated_at = p.avatar_updated_at
      user.save!
    end
  end
end

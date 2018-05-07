# frozen_string_literal: true

class ChangePersonIdToUserIdInVotes < ActiveRecord::Migration
  class TempPerson < ActiveRecord::Base
    self.table_name = 'people'
  end

  class TempVote < ActiveRecord::Base
    self.table_name = 'votes'
  end

  def change
    add_column :votes, :user_id, :integer

    TempPerson.all.each do |t|
      votes = TempVote.where(person_id: t.id)

      unless votes.empty?
        votes.each do |v|
          v.user_id = t.user_id
          v.save!
        end
      end
    end

    remove_column :votes, :person_id
  end
end

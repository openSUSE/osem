# frozen_string_literal: true

class ChangePersonIdToUserIdInRegistrations < ActiveRecord::Migration
  class TempPerson < ApplicationRecord
    self.table_name = 'people'
  end

  class TempRegistration < ApplicationRecord
    self.table_name = 'registrations'
  end

  def change
    add_column :registrations, :user_id, :integer

    TempPerson.all.each do |t|
      registrations = TempRegistration.where(person_id: t.id)

      next if registrations.empty?
      registrations.each do |r|
        r.user_id = t.user_id
        r.save!
      end
    end

    remove_column :registrations, :person_id
  end
end

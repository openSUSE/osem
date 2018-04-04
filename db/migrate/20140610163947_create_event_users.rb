# frozen_string_literal: true

class CreateEventUsers < ActiveRecord::Migration
  class TempPerson < ApplicationRecord
    self.table_name = 'people'
  end

  class TempEventPerson < ApplicationRecord
    self.table_name = 'event_people'
  end

  class TempEventUser < ApplicationRecord
    self.table_name = 'event_users'
  end

  def change
    create_table :event_users do |t|
      t.references :user
      t.references :event
      t.string :event_role, null: false, default: 'participant'
      t.string :comment

      t.timestamps
    end

    TempEventPerson.all.each do |ep|
      record = TempEventUser.new
      record.event_id = ep.event_id
      person = TempPerson.where(id: ep.person_id).first
      record.user_id = person.user_id
      record.event_role = ep.event_role
      record.comment = ep.comment
      record.save!
    end
  end
end

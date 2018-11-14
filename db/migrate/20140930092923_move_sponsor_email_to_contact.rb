# frozen_string_literal: true

class MoveSponsorEmailToContact < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempContact < ActiveRecord::Base
    self.table_name = 'contacts'
  end

  def change
    add_column :contacts, :sponsor_email, :string

    TempConference.all.each do |conference|
      contact = TempContact.find_by(conference_id: conference.id)
      if contact
        contact.sponsor_email = conference.sponsor_email
        contact.save
      else
        Contact.create(conference_id:  conference.id,
                       sponsors_email: conference.sponsor_email)
      end
    end

    remove_column :conferences, :sponsor_email
  end
end

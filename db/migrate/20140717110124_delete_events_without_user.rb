class DeleteEventsWithoutUser < ActiveRecord::Migration
  def up
    # User deletion without all the proper dependent: :destroy options might have left
    # Events without a submitter (event_user association is deleted, but Event itslef is not)
    Event.all.each do |event|
      if event.submitter.blank? || event.speakers.first.blank?
        if event.start_time.present? # If event is scheduled

          # Create dummy user
          unless (user = User.find_by(email: 'deleted@localhost.com'))
            user = User.new(email: 'deleted@localhost.com', name: 'User deleted',
                                biography: 'Data is no longer available for deleted user.',
                                password: Devise.friendly_token[0, 20])
            user.skip_confirmation!
            user.save!
          end

          # Event without submitter
          unless event.event_users.where(event_role: 'submitter').present?
            event.event_users.create!(user: user, event_role: 'submitter')
          end

          # Event without speaker
          unless event.event_users.where(event_role: 'speaker').present?
            event.event_users.create!(user: user, event_role: 'speaker')
          end

          event.event_users.each do |eu|
           unless eu.user.present?
             eu.user = user
             eu.save!
           end
          end

        else
          event.destroy
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot reverse migration. Events deleted cannot be re-created'
  end
end

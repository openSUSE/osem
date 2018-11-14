# frozen_string_literal: true

class AddEventsPerWeekToConference < ActiveRecord::Migration
  class TempVersion < ActiveRecord::Base
    self.table_name = 'versions'
    serialize :object_changes, HashWithIndifferentAccess
  end

  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
    serialize :events_per_week, Hash
  end

  def up
    add_column :conferences, :events_per_week, :text
    TempConference.reset_column_information

    TempVersion.where(item_type: 'Event').each do |event_version|
      event = TempEvent.find_by_id(event_version.item_id)
      if event
        conference = TempConference.find_by_id(event.conference_id)
        if conference
          week = event_version.created_at.end_of_week

          no_events = {
              new:         0,
              withdrawn:   0,
              unconfirmed: 0,
              confirmed:   0,
              canceled:    0,
              rejected:    0,
          }

          if !conference.events_per_week
            conference.events_per_week = {
                week => no_events
            }
          elsif !conference.events_per_week[week]
            conference.events_per_week[week] = no_events
          end

          if event_version.object_changes &&
              event_version.event == 'create'

            # Increment the new state
            conference.events_per_week[week][:new] += 1
          elsif event_version.object_changes &&
              event_version.object_changes[:state]

            prev_state = event_version.object_changes[:state][0].to_sym
            next_state = event_version.object_changes[:state][1].to_sym

            # Backward compatibility: deprecated state :review now :new
            if prev_state == :review
              prev_state = :new
            elsif  next_state == :review
              next_state = :new
            end

            # Increment the next state
            conference.events_per_week[week][next_state] += 1

            # Decrement the previous state
            conference.events_per_week[week][prev_state] -= 1
          end
          conference.save
        end
      end
    end

    # Cumulate the previous weeks to get a snapshot
    TempConference.all.each do |conference|
      hash = conference.events_per_week.sort.to_h
      previous = nil

      hash.each do |week, values|
        if previous
          values.each_key do |state|
            hash[week][state] += previous[state]
          end
        end
        previous = values
      end
      conference.events_per_week = hash
      conference.save
    end
  end

  def down
    remove_column :conferences, :events_per_week
  end
end

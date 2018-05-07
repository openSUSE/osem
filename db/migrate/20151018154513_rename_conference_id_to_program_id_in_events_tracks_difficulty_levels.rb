# frozen_string_literal: true

class RenameConferenceIdToProgramIdInEventsTracksDifficultyLevels < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  class TempEventType < ActiveRecord::Base
    self.table_name = 'event_types'
  end

  class TempTrack < ActiveRecord::Base
    self.table_name = 'tracks'
  end

  class TempDifficultyLevel < ActiveRecord::Base
    self.table_name = 'difficulty_levels'
  end

  class TempProgram < ActiveRecord::Base
    self.table_name = 'programs'
  end

  def up
    add_column :events, :program_id, :integer
    add_column :event_types, :program_id, :integer
    add_column :tracks, :program_id, :integer
    add_column :difficulty_levels, :program_id, :integer

    TempConference.all.each do |conference|
      program = Program.find_by(conference_id: conference.id)

      TempEvent.where(conference_id: conference.id).each do |event|
        event.program_id = program.id
        event.save!
      end

      TempEventType.where(conference_id: conference.id).each do |event_type|
        event_type.program_id = program.id
        event_type.save!
      end

      TempTrack.where(conference_id: conference.id).each do |track|
        track.program_id = program.id
        track.save!
      end

      TempDifficultyLevel.where(conference_id: conference.id).each do |difficulty_level|
        difficulty_level.program_id = program.id
        difficulty_level.save!
      end
    end

    remove_column :events, :conference_id
    remove_column :event_types, :conference_id
    remove_column :tracks, :conference_id
    remove_column :difficulty_levels, :conference_id
  end

  def down
    add_column :events, :conference_id, :integer
    add_column :event_types, :conference_id, :integer
    add_column :tracks, :conference_id, :integer
    add_column :difficulty_levels, :conference_id, :integer

    TempConference.all.each do |conference|
      program = TempProgram.find_by(conference_id: conference.id)

      if program
        TempEvent.where(program_id: program.id).each do |event|
          event.conference_id = conference.id
          event.save!
        end

        TempEventType.where(program_id: program.id).each do |event_type|
          event_type.conference_id = conference.id
          event_type.save!
        end

        TempTrack.where(program_id: program.id).each do |track|
          track.conference_id = conference.id
          track.save!
        end

        TempDifficultyLevel.where(program_id: program.id).each do |difficulty_level|
          difficulty_level.conference_id = conference.id
          difficulty_level.save!
        end
      end
    end

    remove_column :events, :program_id
    remove_column :event_types, :program_id
    remove_column :tracks, :program_id
    remove_column :difficulty_levels, :program_id
  end
end

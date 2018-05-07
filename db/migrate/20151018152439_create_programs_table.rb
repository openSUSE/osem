# frozen_string_literal: true

class CreateProgramsTable < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempCfp < ActiveRecord::Base
    self.table_name = 'cfps'
  end

  class TempCallForPaper < ActiveRecord::Base
    self.table_name = 'call_for_papers'
  end

  class TempProgram < ActiveRecord::Base
    self.table_name = 'programs'
  end

  def up
    create_table :programs do |t|
      t.references :conference
      t.integer :rating, default: 0
      t.boolean :schedule_public, default: false
      t.boolean :schedule_fluid, default: false
      t.timestamps
    end

    add_column :call_for_papers, :program_id, :integer

    TempConference.all.each do |conference|
      unless TempProgram.find_by(conference_id: conference.id)
        program = TempProgram.new
        program.conference_id = conference.id
        program.save!

        if (cfp = TempCallForPaper.find_by(conference_id: conference.id))
          cfp.program_id = program.id
          cfp.save!

          program.rating = cfp.rating
          program.schedule_public = cfp.schedule_public
          program.schedule_fluid = cfp.schedule_changes
          program.save!
        end
      end
    end
    remove_column :call_for_papers, :conference_id
    remove_column :call_for_papers, :rating
    remove_column :call_for_papers, :schedule_public
    remove_column :call_for_papers, :schedule_changes
    rename_table :call_for_papers, :cfps
  end

  def down
    rename_table :cfps, :call_for_papers
    add_column :call_for_papers, :conference_id, :integer
    add_column :call_for_papers, :rating, :integer, default: 0
    add_column :call_for_papers, :schedule_public, :boolean, default: false
    add_column :call_for_papers, :schedule_changes, :boolean, default: false

    TempConference.all.each do |conference|
      if (program = TempProgram.find_by(conference_id: conference.id))
        if (cfp = TempCallForPaper.find_by(program_id: program.id))
          cfp.conference_id = program.conference_id
          cfp.rating = program.rating
          cfp.schedule_public = program.schedule_public
          cfp.schedule_changes = program.schedule_fluid

          cfp.save!
        end
      end
    end

    remove_column :call_for_papers, :program_id
    drop_table :programs
  end
end

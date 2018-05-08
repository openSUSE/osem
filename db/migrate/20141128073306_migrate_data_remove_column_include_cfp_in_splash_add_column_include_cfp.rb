# frozen_string_literal: true

class MigrateDataRemoveColumnIncludeCfpInSplashAddColumnIncludeCfp < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempCallForPaper < ActiveRecord::Base
    self.table_name = 'call_for_papers'
  end

  class TempSplashpage < ActiveRecord::Base
    self.table_name = 'splashpages'
  end

  def up
    add_column :splashpages, :include_cfp, :boolean, default: false

    TempConference.all.each do |conference|
      cfp = TempCallForPaper.find_by(conference_id: conference.id)

      if cfp&.include_cfp_in_splash
        splashpage = TempSplashpage.find_or_initialize_by(conference_id: conference.id)
        splashpage.include_cfp = cfp.include_cfp_in_splash # true
        splashpage.save!
      end
    end

    remove_column :call_for_papers, :include_cfp_in_splash, :boolean, default: false
  end

  def down
    add_column :call_for_papers, :include_cfp_in_splash, :boolean, default: false

    TempConference.all.each do |conference|
      splashpage = TempSplashpage.find_by(conference_id: conference.id)
      cfp = TempCallForPaper.find_by(conference_id: conference.id)

      if splashpage && cfp
        cfp.include_cfp_in_splash = splashpage.include_cfp
        cfp.save!
      end
    end

    remove_column :splashpages, :include_cfp, :boolean, default: false
  end
end

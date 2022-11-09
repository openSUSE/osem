# frozen_string_literal: true

class AddIncludeCfpInSplashToCallForPapers < ActiveRecord::Migration[4.2]
  def change
    add_column :call_for_papers, :include_cfp_in_splash, :boolean, default: false
  end
end

class AddIncludeCfpInSplashpages < ActiveRecord::Migration
  def change
    add_column :splashpages, :include_cfp, :boolean, default: false
  end
end

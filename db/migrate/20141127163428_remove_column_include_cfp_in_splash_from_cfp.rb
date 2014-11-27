class RemoveColumnIncludeCfpInSplashFromCfp < ActiveRecord::Migration
  def change
    remove_column :call_for_papers, :include_cfp_in_splash, :boolean, default: false
  end
end

class AddIncludeHappeningNowToSplashpages < ActiveRecord::Migration[5.2]
  def change
    add_column :splashpages, :include_happening_now, :boolean
  end
end

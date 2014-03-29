class AddYoutubeToMediaType < ActiveRecord::Migration
  def up    
    Event.where(:media_type => nil).each do |e|
      e.media_type = "YouTube"
      e.save(:validate => false)
    end
  end
end

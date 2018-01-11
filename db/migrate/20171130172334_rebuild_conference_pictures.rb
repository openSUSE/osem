class RebuildConferencePictures < ActiveRecord::Migration
  def up
    Conference.all.each do |conference|
      conference.picture.recreate_versions!
    end
  end

  def down; end
end

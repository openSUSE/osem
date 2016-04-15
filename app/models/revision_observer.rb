#
# suseconferenceclient relies on a 'revision' attribute for caching and
# doing some calculations.
#
# It should be incremented after any change in the conference or in any
# associated models
#
# This observer updates the revision column in a non-intrusive way,
# preventing validations, callbacks or exceptions to be triggered
#
# Relying on paper_trail could also be an option, but a 'revision' column
# in table 'conferences' looks like a more simple and straightforward solution
#
class RevisionObserver < ActiveRecord::Observer
  observe :conference, :event, :room, :track

  def after_save(model)
    begin
      conference = model.kind_of?(Conference) ? model : model.conference
      conference.reload.increment(:revision)
      conference.update_column(:revision, conference.revision)
    rescue
      nil
    end
  end
end

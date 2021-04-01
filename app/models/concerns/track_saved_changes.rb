# https://github.com/ccmcbeck/after-commit
module TrackSavedChanges
  extend ActiveSupport::Concern

  included do
    # expose the details if consumer wants to do more
    attr_reader :saved_changes_history, :saved_changes_unfiltered
    after_initialize :reset_saved_changes
    after_save :track_saved_changes
  end

  # on initalize, but useful for fine grain control
  def reset_saved_changes
    @saved_changes_unfiltered = {}
    @saved_changes_history = []
  end

  # filter out any changes that result in the original value
  def saved_changes
    @saved_changes_unfiltered.reject { |k,v| v[0] == v[1] }
  end

  private

  # on save
  def track_saved_changes
    # maintain an array of ActiveModel::Dirty.changes
    @saved_changes_history << changes.dup
    # accumulate the most recent changes
    @saved_changes_history.last.each_pair { |k, v| track_saved_change k, v }
  end

  # v is an an array of [prev, current]
  def track_saved_change(k, v)
    if @saved_changes_unfiltered.key? k
      @saved_changes_unfiltered[k][1] = track_saved_value v[1]
    else
      @saved_changes_unfiltered[k] = v.dup
    end
  end

  # type safe dup inspred by http://stackoverflow.com/a/20955038
  def track_saved_value(v)
    begin
      v.dup
    rescue TypeError
      v
    end
  end
end
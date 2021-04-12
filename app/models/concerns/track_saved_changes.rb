# https://github.com/ccmcbeck/after-commit
module TrackSavedChanges
  extend ActiveSupport::Concern

  included do
    # expose the details if consumer wants to do more
    # attr_reader :ts_saved_changes_history, :ts_saved_changes_unfiltered
    after_initialize :ts_reset_saved_changes
    after_save :ts_track_saved_changes
  end

  # on initalize, but useful for fine grain control
  def ts_reset_saved_changes
    @ts_saved_changes_unfiltered = {}
    @ts_saved_changes_history = []
  end

  # filter out any changes that result in the original value
  def ts_saved_changes
    @ts_saved_changes_unfiltered.reject { |_k, v| v[0] == v[1] }
  end

  private

  # on save
  def ts_track_saved_changes
    # maintain an array of ActiveModel::Dirty.changes
    @ts_saved_changes_history << previous_changes.dup
    # accumulate the most recent changes
    @ts_saved_changes_history.last.each_pair { |k, v| ts_track_saved_change k, v }
  end

  # v is an an array of [prev, current]
  def ts_track_saved_change(key, value)
    if @ts_saved_changes_unfiltered.key? key
      @ts_saved_changes_unfiltered[key][1] = ts_track_saved_value value[1]
    else
      @ts_saved_changes_unfiltered[key] = value.dup
    end
  end

  # type safe dup inspred by http://stackoverflow.com/a/20955038
  def ts_track_saved_value(value)
    value.dup
  rescue TypeError
    value
  end
end

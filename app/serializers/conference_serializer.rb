class ConferenceSerializer < ActiveModel::Serializer
  attributes :guid, :name, :description, :year, :socialtag, :date_range, :url, :revision

  def name
    object.title
  end

  def year
    object.start_date.try(:year)
  end

  def socialtag
    object.contact.social_tag
  end

  def revision
    object.revision || 0
  end

  # FIXME: adjusting the format the DIRTY way, for oSC13.
  # If you think this is ugly, don't look at the methods below
  def date_range
    object.date_range_string.try(:split, ',').try(:first)
  end

  # FIXME: just giving suseconferenceclient something to play with
  def description
    'openSUSE Conference 2013 - Power to the Geeko'
  end

  # FIXME: same than the former
  def url
    'https://conference.opensuse.org/'
  end
end

class ConferenceSerializer < ActiveModel::Serializer
  attributes :guid, :name, :description, :year, :socialtag, :date_range#, :url, :revision

  def name
    object.short_title
  end

  def description
    object.title
  end

  def year
    object.start_date.try(:year)
  end

  def socialtag
    object.social_tag
  end

  def date_range
    object.date_range_string
  end
end

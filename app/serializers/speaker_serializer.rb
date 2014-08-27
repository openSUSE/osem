class SpeakerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :name, :affiliation, :biography

  def name
    object.name
  end

  def biography
    if object.biography.blank?
      nil
    else
      simple_format(object.biography).gsub('\n', '')
    end
  end
end

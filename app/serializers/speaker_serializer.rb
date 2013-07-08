class SpeakerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :guid, :name, :company, :biography

  def name
    object.public_name
  end

  def biography
    if object.biography.blank?
      nil
    else
      simple_format(object.biography).gsub("\n", "")
    end
  end
end

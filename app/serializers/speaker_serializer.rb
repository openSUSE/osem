class SpeakerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :guid, :name, :full_name, :company, :biography

  def name
    object.public_name
  end

  def full_name
    [object.first_name, object.last_name].join(" ")
  end

  def biography
    if object.biography.blank?
      nil
    else
      simple_format(object.biography).gsub("\n", "")
    end
  end
end

class SpeakerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :name, :affiliation, :biography

  def name
    object.name
  end
end

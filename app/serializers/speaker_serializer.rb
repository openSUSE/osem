# frozen_string_literal: true

class SpeakerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  attributes :url, :name, :affiliation, :biography

  delegate :name, to: :object

  def url
    url_for(object)
  end
end

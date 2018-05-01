# frozen_string_literal: true

class SpeakerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :name, :affiliation, :biography

  delegate :name, to: :object
end

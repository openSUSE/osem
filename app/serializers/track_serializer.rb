# frozen_string_literal: true

class TrackSerializer < ActiveModel::Serializer
  attributes :guid, :name, :color
end

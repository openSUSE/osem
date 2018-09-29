# frozen_string_literal: true

#
# Needed in order to add the API version number to the conferences array
#
class ConferencesArraySerializer < ActiveModel::Serializer::CollectionSerializer
  def as_json(*args)
    json = super
    json.merge!(version: 1)
  end
end

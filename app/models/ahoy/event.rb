# frozen_string_literal: true

module Ahoy
  class Event < ApplicationRecord
    self.table_name = 'ahoy_events'

    belongs_to :visit
    belongs_to :user

    serialize :properties, JSON
  end
end

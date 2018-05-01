# frozen_string_literal: true

module ActiveRecord
  class Base
    mattr_accessor :shared_connection
    @@shared_connection = nil

    def self.connection
      @@shared_connection || retrieve_connection
    end
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

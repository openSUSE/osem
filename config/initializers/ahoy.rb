module Ahoy
  class Store < Ahoy::DatabaseStore
    def visit_model
      Visit
    end
  end
end

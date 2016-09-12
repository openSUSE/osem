module Api
  module V1
    class ConferencesController < Api::BaseController
      load_resource find_by: :short_title
      respond_to :json

      def index
        render json: @conferences, serializer: ConferencesArraySerializer, callback: params['callback']
      end

      def show
        render json: [@conference], serializer: ConferencesArraySerializer, callback: params['callback']
      end
    end
  end
end

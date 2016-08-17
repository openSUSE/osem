module Admin
  class EventSchedulesController < Admin::BaseController
    load_and_authorize_resource :event_schedule

    def bulk_create
      result = EventSchedule.create(params[:event_schedules].values).reject { |p| p.errors.empty? }
      if result.empty?
        render json: {}
      else
        event_names = result.collect { |event_schedule| event_schedule.event.try(:title) }
        render json: { errors: event_names.to_s }, status: 422
      end
    end

    def bulk_update
      keys = []
      values = []
      params[:event_schedules].values.each do |e|
        keys << e.keys[0]
        values << e.values[0]
      end
      result = EventSchedule.update(keys, values).reject { |p| p.errors.empty? }
      if result.empty?
        render json: {}
      else
        event_names = result.collect { |event_schedule| event_schedule.event.try(:title) }
        render json: { errors: event_names.to_s }, status: 422
      end
    end

    def bulk_destroy
      result = EventSchedule.destroy(params[:event_schedules].values).reject { |p| p.errors.empty? }
      if result.empty?
        render json: {}
      else
        event_names = result.collect { |event_schedule| event_schedule.event.try(:title) }
        render json: { errors: event_names.to_s }, status: 422
      end
    end
  end
end

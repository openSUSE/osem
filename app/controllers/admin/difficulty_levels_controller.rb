class Admin::DifficultyLevelsController < ApplicationController
  before_filter :verify_organizer
  
  def index
    @conference = Conference.where(short_title: params[:conference_id]).first
  end

  def update
    if @conference.update_attributes(params[:conference])
      if !(@conference.difficulty_levels.count > 0) && @conference.use_difficulty_levels == true
        begin 
          @conference.use_difficulty_levels = false
          @conference.save!
          flash[:error] = "You cannot enable the usage of difficulty levels without having set any levels."
          redirect_to(admin_conference_difficulty_levels_path(:conference_id => @conference.short_title))
        rescue ActiveRecord::RecordInvalid
          flash[:error] = "Something went wrong. Difficulty Levels update failed."
          redirect_to(admin_conference_difficulty_levels_path(:conference_id => @conference.short_title))  
        end
      else
        flash[:notice] = "Difficulty Levels were successfully updated."
        redirect_to(admin_conference_difficulty_levels_path(:conference_id => @conference.short_title))
      end
    else
      flash[:error] = "Difficulty Levels update failed."
      redirect_to(admin_conference_difficulty_levels_path(:conference_id => @conference.short_title))
    end

  end
end
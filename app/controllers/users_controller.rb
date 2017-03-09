class UsersController < ApplicationController
  load_and_authorize_resource

  # GET /users/1
  def show
    @events = @user.events.where(state: :confirmed)
  end

  # GET /users/1/edit
  def edit
    @tab_select = params[:tab]
    if @tab_select.present?
      respond_to do |format|
        format.js { render action: 'field_select' }
      end
    else
      render :edit
    end
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if @user.update(user_params)
        flash[:notice] = 'User was successfully updated.'
      else
        flash[:error] = "An error prohibited your Profile from being saved: #{@user.errors.full_messages.join('. ')}."
      end
      format.js
    end
  end

  private

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :biography, :nickname, :affiliation, :googleplus, :twitter, :gna, :gnu, :github, :gitlab, :website_url, :linkedin, :diaspora, :savannah)
    end
end

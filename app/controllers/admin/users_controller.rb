class Admin::UsersController < ApplicationController
  before_filter :verify_admin
  layout "admin"

  def index
    @users = User.all(:joins => :person,
                      :order => "people.last_name ASC",
                      :select => "users.*,
                                  people.last_name AS last_name,
                                  people.first_name AS first_name,
                                  people.public_name AS public_name,
                                  people.email AS email")
  end

  def update
    user = User.find(params[:id])
    user.update_attributes!(params[:user])
    redirect_to admin_users_path, :notice => "Updated #{user.email}"
  end
end

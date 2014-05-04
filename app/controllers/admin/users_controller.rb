class Admin::UsersController < ApplicationController
  before_filter :verify_admin

  def index
    @users = User.select('users.*,
                                  people.last_name AS last_name,
                                  people.first_name AS first_name,
                                  people.public_name AS public_name,
                                  people.email AS email').
                                  joins(:person).load.
                                  order('people.last_name ASC')
  end

  def update
    user = User.find(params[:id])
    user.update_attributes!(params[:user])
    redirect_to admin_users_path, :notice => "Updated #{user.email}"
  end

  def delete
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, :notice => "User got deleted"
    
  end  

end

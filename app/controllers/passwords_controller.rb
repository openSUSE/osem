class PasswordsController < Devise::PasswordsController
	skip_before_filter :verify_user
	def new
		super
	end

	def edit
		super
		
	end

	def update
		@user = User.find_by_reset_password_token(params[:user][:reset_password_token])
		logger.debug "#{@user.email}"
		password_changed = false
	    if !params[:user][:password].nil?
	      if !params[:user][:password].empty?
	          password_changed = true
	      else
	        params[:user].delete :password
	        params[:user].delete :password_confirmation
	      end
	    end
	    
	    if password_changed
	      successfully_updated = @user.reset_password!(params[:user][:password],params[:user][:password_confirmation])
	    else
	      redirect_to session[:return_to], :notice => "Blank Field Entered" and return
	    end

	    if successfully_updated
	    	redirect_to root_path, :notice => "Your password is changed" and return
	    else
	    	redirect_to session[:return_to] and return
	    end	
  end

end
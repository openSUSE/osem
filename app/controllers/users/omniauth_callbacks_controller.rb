class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token

  [:novell, :google, :facebook, :twitter].each do |provider|
    define_method(provider) { handle(provider) }
  end

  private
    def handle(provider)

      auth_hash = request.env['omniauth.auth']
      openid = Openid.find_for_oauth(auth_hash) # Get or create openid
      # If openid exists and is associated with a user, sign in with associated user,
      # even if the email of the associated user and the email of the provided openid are different
      unless user = openid.user
        user = User.find_for_auth(auth_hash, current_user) # Get or create users
      end

      begin
        user.save!
        if openid.user != user
          openid.user = user
        end
        openid.save!

        sign_in user
        redirect_to root_path, notice: user.email + " signed in successfully with #{provider}"
      rescue Exception => e
        redirect_back_or_to new_user_registration_path, alert: 'Failed' + e.message
      end
    end
end
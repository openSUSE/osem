# frozen_string_literal: true

namespace :user do
  desc "Makes is_admin attribute true for user based on the supplied email address."
  task :admin, [:email] => :environment do |t, args|

    # Check if an email address was supplied
    fail 'You need to define the email address of the user you want to make an admin.' unless args.email

    user = User.find_by(email: args.email)
    # Check if a user is found based on the supplied email address
    fail "There is no user with email #{args.email}!" unless user

    if user.update_columns(is_admin: true)
      puts "User with email #{args.email} is now an admin!"
    end
  end

  desc "Set email_public attrubute true for all users"
  task :set_email_public => :environment do
    User.update_all email_public: true
  end
end

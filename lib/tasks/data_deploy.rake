# frozen_string_literal: true

namespace :data do
  desc 'Create demo data for production systems'

  task deploy: :environment do
    include FactoryBot::Syntax::Methods
    conference = create(:full_conference, title: 'Your Own Open Source Event Manager',
                                          short_title: 'yourosem',
                                          description: "This is your new [Open Source Event Manager](http://osem.io/) instance. The first user to [sign up](/accounts/sign_up) will the be administrator of this instance. You can safely delete this conference once you have checked out all the features. We hope you enjoy using OSEM, if you have any question don't hesitate to [contact us](http://osem.io/#contact)!")
  end
end

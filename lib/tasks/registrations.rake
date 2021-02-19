# frozen_string_literal: true

namespace :registrations do
  desc 'Create missing registrations for those how have a registration ticket.'
  task :create_missing, [:conference] => :environment do |_t, args|

    raise 'Please supply a conference short name.' unless args.conference

    conf = Conference.find_by(short_title: args.conference)
    # Check if a user is found based on the supplied email address
    raise "Coud not find conference #{args.conference}" unless conf

    purchases = conf.ticket_purchases.where(ticket: conf.registration_tickets, paid: true)
    unregistered = purchases.reject { |tp| conf.user_registered?(tp.user) }
    puts "Found #{unregistered.count} unregistered users for #{purchases.count} ticket purchases."
    puts "There are currently #{conf.participants.count} registered users."

    unregistered.each do |tp|
      puts "Creating registration for #{tp.user.email}"
      Registration.create(user: tp.user, conference: conf)
    end
    puts 'Done.'
  end

  desc 'Show User emails who have not paid, but did register'
  task :list_unpaid, [:conference] => :environment do |_t, args|

    raise 'Please supply a conference short name.' unless args.conference

    conf = Conference.find_by(short_title: args.conference)
    # Check if a user is found based on the supplied email address
    raise "Coud not find conference #{args.conference}" unless conf

    registered = conf.participants
    unpaid = registered.select do |user|
      TicketPurchase.where(conference: conf, paid: true, user: user).empty?
    end
    puts "Found #{registered.count} registered users and #{unpaid.count} unpaid attendees."
    puts

    unpaid.each do |user|
      puts "'#{user.name}'<#{user.email}>, "
    end
    puts ''
  end
end

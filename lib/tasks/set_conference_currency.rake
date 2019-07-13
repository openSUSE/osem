# frozen_string_literal: true

namespace :data do
  desc 'Sets price_currency in all pre-existing Conference records'
  task set_conference_price_currency: :environment do
    Conference.all.each do |conference|
      # if ticket has price_currency it is old and needs to be updated
      if conference.tickets.first.price_currency
        # check all tickets have same price currency
        ticket_pc = conference.tickets.first.price_currency
        make_change = true
        conference.tickets.each do |ticket|
          make_change = false unless ticket.price_currency == ticket_pc
        end
      end
      if make_change
        conference.update(price_currency: ticket_pc)
        puts "price currency of #{ticket_pc} set for conference: #{conference.title}."
      else
        puts "price currency discrepancy between tickets for conference: #{conference.title}, please check and try again."
      end
    end
  end
end

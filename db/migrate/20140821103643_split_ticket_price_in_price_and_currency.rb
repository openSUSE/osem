# frozen_string_literal: true

class SplitTicketPriceInPriceAndCurrency < ActiveRecord::Migration
  class TempTicket < ActiveRecord::Base
    self.table_name = 'tickets'
  end

  def change
    adapter_type = connection.adapter_name.downcase.to_sym

    case adapter_type
    when :postgresql
      add_monetize :tickets, :price
    else
      add_money :tickets, :price
    end

    TempTicket.all.each do |ticket|
      # Replace currency symbol with ISO Code
      if ticket.ticket_price
        ticket.ticket_price.gsub!('€', 'EUR')
        ticket.ticket_price.gsub!('$', 'USD')
        ticket.ticket_price.gsub!('£', 'GBP')
        ticket.ticket_price.gsub!('¥', 'CNY')
        ticket.ticket_price.gsub!('₹', 'INR')

        money = ticket.ticket_price.to_money
        ticket.price_cents = money.cents
        ticket.price_currency = money.currency_as_string
        ticket.save
      end
    end

    remove_column :tickets, :ticket_price
    remove_column :tickets, :url
  end
end

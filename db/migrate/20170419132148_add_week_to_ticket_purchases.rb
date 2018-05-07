# frozen_string_literal: true

class AddWeekToTicketPurchases < ActiveRecord::Migration
  class TmpTicketPurchase < ActiveRecord::Base
    self.table_name = 'ticket_purchases'
  end

  def change
    add_column :ticket_purchases, :week, :integer

    TmpTicketPurchase.reset_column_information
    TmpTicketPurchase.find_each do |purchase|
      purchase.week = purchase.created_at ? purchase.created_at.strftime('%W') : 0
      purchase.save!
    end
  end
end

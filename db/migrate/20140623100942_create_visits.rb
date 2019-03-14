# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration
  def change
    adapter_type = connection.adapter_name.downcase.to_sym

    create_table :visits do |t|
      case adapter_type
      when :postgresql
        t.uuid :visitor_id
      else
        t.integer :visitor_id
      end

      # the rest are recommended but optional
      # simply remove the columns you don't want

      # standard
      t.string :ip
      t.text :user_agent
      t.text :referrer
      t.text :landing_page

      # user
      t.integer :user_id
      # add t.string :user_type if polymorphic

      # traffic source
      t.string :referring_domain
      t.string :search_keyword

      # technology
      t.string :browser
      t.string :os
      t.string :device_type

      # location
      t.string :country
      t.string :region
      t.string :city

      # utm parameters
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_term
      t.string :utm_content
      t.string :utm_campaign

      # native apps
      # t.string :platform
      # t.string :app_version
      # t.string :os_version

      t.timestamp :started_at
    end

    add_index :visits, [:user_id]
  end
end

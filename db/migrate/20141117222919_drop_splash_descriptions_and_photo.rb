# frozen_string_literal: true

class DropSplashDescriptionsAndPhoto < ActiveRecord::Migration
  def change
    remove_column :splashpages, :ticket_description
    remove_column :splashpages, :sponsor_description
    remove_column :splashpages, :registration_description
    remove_column :splashpages, :lodging_description
    remove_column :splashpages, :include_banner
    remove_attachment :splashpages, :banner_photo
  end
end

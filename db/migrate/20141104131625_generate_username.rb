# frozen_string_literal: true

class GenerateUsername < ActiveRecord::Migration
  class TempUser < ApplicationRecord
    self.table_name = 'users'
  end

  def change
    TempUser.all.each do |user|
      next if user.username.present?
      username = user.email.split('@')[0]
      username += user.id.to_s if TempUser.find_by(username: username)
      user.update(username: username)
    end
  end
end

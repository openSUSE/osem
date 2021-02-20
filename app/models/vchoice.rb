# frozen_string_literal: true

# == Schema Information
#
# Table name: vchoices
#
#  id           :bigint           not null, primary key
#  vday_id      :integer
#  vposition_id :integer
#
class Vchoice < ApplicationRecord
  belongs_to :vday
  belongs_to :vposition

  has_and_belongs_to_many :registrations
end

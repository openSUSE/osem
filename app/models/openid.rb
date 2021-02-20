# frozen_string_literal: true

# == Schema Information
#
# Table name: openids
#
#  id         :bigint           not null, primary key
#  email      :string
#  provider   :string
#  uid        :string
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#
class Openid < ApplicationRecord
  belongs_to :user
  validates :provider, :uid, :email, presence: true

  # Searches for openid based on provider and uid.
  # Returns found openid or a new openid.
  # ====Returns
  # * Openid::ActiveRecord_Relation -> openid
  def self.find_for_oauth(auth)
    openid = Openid.where(provider: auth.provider, uid: auth.uid).first_or_initialize

    if openid.new_record?
      openid.email = auth.info.email
      if (existing_openid = Openid.where(email: openid.email).first)
        openid.user_id = existing_openid.user_id
      end
    end
    openid
  end
end

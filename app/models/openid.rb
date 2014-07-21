class Openid < ActiveRecord::Base
  belongs_to :user
  validates :provider, :uid, presence: true

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

# frozen_string_literal: true

require 'securerandom'

class BulkEmailSession < ApplicationRecord
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  validates :token, presence: true, uniqueness: true
  validates :recipient_emails, presence: true

  serialize :recipient_emails, type: Array

  # Sessions expire after 1 hour to prevent database bloat
  EXPIRATION_TIME = 1.hour

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def self.cleanup_expired!
    expired.delete_all
  end

  def expired?
    expires_at <= Time.current
  end

  def recipient_count
    recipient_emails&.size || 0
  end

  private

  def generate_token
    return if token.present?

    self.token = SecureRandom.hex(16)
  end

  def set_expiration
    return if expires_at.present?

    self.expires_at = EXPIRATION_TIME.from_now
  end
end
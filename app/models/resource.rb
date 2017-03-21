class Resource < ActiveRecord::Base
  belongs_to :conference
  validates :name, :used, :quantity, presence: true
  validates :used, :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :used_no_more_than_quantity

  private

  def used_no_more_than_quantity
    errors.add(:used, 'cannot be higher than total quantity') if used.present? && quantity.present? && used > quantity
  end
end

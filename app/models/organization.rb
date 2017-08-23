class Organization < ActiveRecord::Base
  resourcify :roles, dependent: :delete_all

  has_paper_trail

  has_many :conferences, dependent: :destroy

  after_create :create_roles

  validates :name, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :picture

  private

  def create_roles
    roles.where(name: 'organization_admin').first_or_create(description: 'For the administrators of an organization and its conferences')
  end
end

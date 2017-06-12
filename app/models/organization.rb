class Organization < ActiveRecord::Base
  resourcify :roles, dependent: :delete_all

  has_many :conferences, dependent: :destroy

  after_create :create_roles

  validates :name, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :picture

  private

  def create_roles
    Role.where(name: 'organization_admin', resource: self).first_or_create(description: "For the administrators of an organization (who shall have full access to the organization and it's conferences)")
  end
end

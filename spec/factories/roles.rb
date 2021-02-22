# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  description   :string
#  name          :string
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#  resource_id   :integer
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#
FactoryBot.define do
  factory :role do
    name { 'my role' }

    factory :organizer_role do
      name { 'organizer' }
    end

    factory :cfp_role do
      name { 'cfp' }
    end

    factory :info_desk_role do
      name { 'info_desk' }
    end

    factory :volunteers_coordinator_role do
      name { 'volunteers_coordinator' }
    end
  end
end

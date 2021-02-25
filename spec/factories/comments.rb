# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  body             :text
#  commentable_type :string
#  lft              :integer
#  rgt              :integer
#  subject          :string
#  title            :string(50)       default("")
#  created_at       :datetime
#  updated_at       :datetime
#  commentable_id   :integer
#  parent_id        :integer
#  user_id          :integer
#
# Indexes
#
#  index_comments_on_commentable_id    (commentable_id)
#  index_comments_on_commentable_type  (commentable_type)
#  index_comments_on_user_id           (user_id)
#

FactoryBot.define do
  factory :comment do
    body { 'Most interresting comment ever, created by a girl.' }
    user
    association :commentable, factory: :event
  end
end

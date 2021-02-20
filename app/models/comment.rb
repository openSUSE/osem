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
class Comment < ApplicationRecord
  acts_as_nested_set scope: %i(commentable_id commentable_type)
  validates :body, presence: true
  validates :user, presence: true
  after_create :send_notification

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_votable

  belongs_to :commentable, counter_cache: true, polymorphic: true

  # NOTE: Comments belong to a user
  belongs_to :user

  has_paper_trail on: %i(create destroy), meta: { conference_id: :conference_id }

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    new \
      commentable: obj,
      body:        comment,
      user_id:     user_id
  end

  #helper method to check if a comment has children
  def has_children?
    children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(user_id: user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(commentable_type: commentable_str.to_s, commentable_id: commentable_id).order('created_at DESC')
  }

  scope :find_since_last_login, lambda { |user|
    if user.last_sign_in_at
      where(created_at: (user.last_sign_in_at..Time.now)).order(created_at: :desc)
    else
      none
    end
  }
  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  private

  def send_notification
    EventCommentMailJob.perform_later(self)
  end

  def conference_id
    commentable.program.conference_id
  end
end

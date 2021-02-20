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
require 'spec_helper'

describe Commercial do

  describe '.find_since_last_login' do
    let!(:user) do
      create(:user, last_sign_in_at: nil)
    end

    it 'returns none if last_sign_in_at is nil' do
      expect(Comment.find_since_last_login(user)).to eq(Comment.none)
    end
  end
end

# frozen_string_literal: true

class EventCommentMailJob < ApplicationJob
  queue_as :default

  def perform(comment)
    User.comment_notifiable(comment.conference_id).each do |user|
      Mailbot.event_comment_mail(comment, user).deliver_now
    end
  end
end

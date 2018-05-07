# frozen_string_literal: true

class EventCommentMailJob < ApplicationJob
  queue_as :default

  def perform(comment)
    conference = comment.commentable.program.conference

    User.comment_notifiable(conference).each do |user|
      Mailbot.event_comment_mail(comment, user).deliver_now
    end
  end
end

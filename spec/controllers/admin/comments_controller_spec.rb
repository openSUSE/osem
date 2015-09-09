require 'spec_helper'

describe Admin::CommentsController do

# some settings to be done before like creating objects used by tests
  describe 'GET #index' do
    context 'all comments' do
      it 'populates a hash with conference, event, and comment objects'
      it 'renders the :index template'
    end

    context 'unread_comments' do
      it 'populates a hash with conference, event, and comment objects created since last login of current_user'
      it 'renders the :index template'
    end

    context 'posted_comments' do
      it 'populates a hash with conference, event, and comments posted by current_user'
      it 'renders the :index template'
    end
  end

  describe 'accessible_ordered_comments' do
    it 'returns comments'
    it 'sorts comments by created_at and event title'
  end

  describe 'grouped_comments(remarks)' do
    it 'groups comments by conference and by event'
    it 'returns a hash'
  end
end

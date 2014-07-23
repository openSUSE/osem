require 'spec_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }
    let(:user){ nil }

    context "when is an admin" do
      let!(:user) { create(:admin) }

      it{ should be_able_to(:manage, Event.new) }
    end

    context "when is an participant" do
      let(:user) { build(:participant) }

      it{ should_not be_able_to(:manage, Event.new) }
      it{ should be_able_to(:create, Event.new) }
      it{ should be_able_to(:read, Event.new) }
    end

    context "when is an event owner" do
      let(:user) { create(:participant) }
      let(:user2) { create(:participant) }
      let(:myevent) { create(:event, users: [user]) }
      let(:someevent) { create(:event, users: [user2]) }

      # Users are able to update and destroy their own events
      it{ should be_able_to(:update, myevent) }
      it{ should be_able_to(:destroy, myevent) }

      # Users are not able to update and destroy other users events
      it{ should_not be_able_to(:update, someevent) }
      it{ should_not be_able_to(:destroy, someevent) }
    end

  end
end

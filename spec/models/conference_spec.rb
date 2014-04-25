require 'spec_helper'

describe Conference do

  let(:subject) { create(:conference) }

  describe "#registration_open?" do

    context "closed registration" do

      it "#registration_open? is false" do
        expect(subject.registration_open?).to be false
      end

    end

    context "open registration" do

      before do
        subject.registration_start_date = Date.today - 1
        subject.registration_end_date = Date.today + 7
      end

      it "#registration_open? is true" do
        expect(subject.registration_open?).to be true
      end

    end

  end

  describe "#cfp_open?" do

    context "closed cfp" do

      it "#cfp_open? is false" do
        expect(subject.cfp_open?).to be false
      end

    end

    context "open cfp" do

      before do
        subject.call_for_papers = create(:call_for_papers)
      end

      it "#registration_open? is true" do
        expect(subject.cfp_open?).to be true
      end

    end

  end

  describe "#user_registered?" do

    let(:user) { create(:user) }

    context "user not registered" do
      it "#user_registered? is false" do
        expect(subject.user_registered? user).to be false
      end
    end

    context "user registered" do
      pending "isn't tested yet"
    end

  end
 
end

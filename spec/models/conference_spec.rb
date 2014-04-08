require 'spec_helper'

describe Conference do
  before do
    @conference = create(:conference)
  end
  

  describe "#registration_open?" do
  	context "closed registration" do
  	  it "#registration_open? is false" do
  	    expect(@conference.registration_open?).to be false
      end
  	end

  	context "open registration" do
  	  before do
    	@conference.registration_start_date = Date.today - 1
    	@conference.registration_end_date = Date.today + 7
  	  end
  	  it "#registration_open? is true" do
  		expect(@conference.registration_open?).to be true
  	  end
  	end
  end

  describe "#cfp_open?" do
  	context "closed cfp" do
  	  it "#cfp_open? is false" do
  	    expect(@conference.cfp_open?).to be false
      end
  	end

  	context "open cfp" do
  	  before do
  	  	@cfp = create(:call_for_papers)
  	  	@conference.call_for_papers = @cfp
  	  end
  	  it "#registration_open? is true" do
  		expect(@conference.cfp_open?).to be true
  	  end
  	end
  end

  describe "#user_registered?" do
  	before do
  		@user = create(:user)
  	end
  	context "user not registered" do
  	  it "#user_registered? is false" do
  	    expect(@conference.user_registered? @user).to be false
      end
  	end

  	context "user registered" do
  	  pending "isn't tested yet"
  	end
  end
 
end

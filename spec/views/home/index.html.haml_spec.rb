require 'spec_helper'

describe 'home/index' do
   it "renders _conference partial for each conference" do
    assign(:current, [create(:conference), create(:conference)])
    render
    expect(view).to render_template(:partial => "_conference_details", :count => 2)
  end
end

require 'spec_helper'

describe "admin/rooms/index" do
  it 'renders conference sidebar' do
    expect(sidebar).to be true
  end
  it 'renders rooms list' do
    @room = create(:room)
    assign :conference, @room.conference
    render
    expect(rendered).to include('Example Room')
    expect(rendered).to include('4')
  end
end
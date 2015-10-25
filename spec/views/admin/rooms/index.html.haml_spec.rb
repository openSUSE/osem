require 'spec_helper'

describe 'admin/rooms/index' do

  it 'renders rooms list' do
    conference = create(:conference)
    create(:room, name: 'Example Room', size: 4, program: conference.program)
    assign :conference, conference
    render
    expect(rendered).to include('Example Room')
    expect(rendered).to include('4')
  end

end

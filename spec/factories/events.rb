# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "The ##{n} talk you'll ever attend." }
    event_type
    conference
    association :room, factory: :room_for_100
    abstract <<-EOS
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ante
      lacus, mollis non urna vitae, varius semper leo. Nulla ac nibh dui. Mauris
      convallis diam eu porta fermentum. Vestibulum posuere odio et est ornare,
      at consectetur ante eleifend. Etiam tellus libero, ornare at euismod nec,
      luctus a leo. Aliquam et commodo lacus, at luctus nibh. Aenean eleifend
      risus a nisi pellentesque tempor. Etiam dapibus facilisis odio at ornare.
      Mauris tempus, nunc ut malesuada iaculis, eros mi mattis ligula, vitae
      lobortis enim lacus ut nunc. Donec mattis sagittis imperdiet.
      Pellentesque ultrices malesuada ipsum, mattis dignissim felis pulvinar
      vitae. Etiam ultrices erat convallis arcu placerat, at vulputate felis
      tempus. Ut eleifend sem et ante feugiat euismod ac luctus tortor. Nam
      commodo mattis erat ac condimentum. Duis dictum tempus odio, quis
      adipiscing justo. Etiam nunc neque, rutrum vitae sapien eget, elementum
      dignissim dui.

      Donec vitae laoreet augue. Sed eget felis placerat, scelerisque felis eu,
      mattis risus. Sed posuere arcu at lacus ultricies pretium. Aenean in
      dapibus erat. Morbi vitae risus eu ante lacinia mollis. Donec vitae
      hendrerit est. Maecenas ac sem non mi vulputate aliquam ac eget enim.
      Curabitur eget volutpat nisi. Proin sit amet consequat urna. Aliquam nec
      elit vitae tellus pellentesque ultricies. Sed in enim vitae nisl
      ullamcorper dignissim. Proin aliquet nisi sed mauris dapibus, sit amet
      dignissim quam pulvinar. Nunc dictum porta sodales. Cras ullamcorper
      libero quis porta ultricies. Fusce pulvinar accumsan lobortis.
    EOS
    after(:build) do |event|
      event.event_users << build(:submitter, event: event)
    end
  end
end

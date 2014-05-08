# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    first_name 'Pat'
    last_name 'Jones'
    email 'pjones@nowhere.net'
    biography <<-EOS
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus enim
      nunc, venenatis non sapien convallis, dictum suscipit purus. Vestibulum
      sed tincidunt tortor. Fusce viverra nisi nisi, quis congue dui faucibus
      nec. Sed sodales suscipit nulla, accumsan porttitor augue ultrices vel.
      Quisque cursus facilisis consequat. Etiam volutpat ligula turpis, at
      gravida.
    EOS
  end

end

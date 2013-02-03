class DatatableSupporters < Datatable
  def data
    arr = []
    items.each do |i|
      item = []
      if i.name.blank?
        item << i.registration.person.public_name
      else
        item << i.name
      end

      if i.email.blank?
        item << i.registration.person.email
      else
        item << i.email
      end

      item << i.supporter_level.title
      item << i.code
      item << i.code_is_valid
      arr << item
    end

    arr
  end

  def columns
    ["name", "email", "name", "name", "name"]
  end
end
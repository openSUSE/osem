require 'spec_helper'

describe Commercial do

  it { should validate_presence_of(:commercial_id) }
  it { should validate_presence_of(:commercial_type) }

end

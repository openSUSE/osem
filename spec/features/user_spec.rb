# frozen_string_literal: true

require 'spec_helper'

feature User do

  shared_examples 'admin ability' do

  end

  describe 'admin' do
    it_behaves_like 'admin ability', :admin
  end
end

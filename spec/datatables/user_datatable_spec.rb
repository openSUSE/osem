# frozen_string_literal: true

require 'spec_helper'

describe UserDatatable do
  subject!(:user_datatable) do
    described_class.new(view)
  end

  let(:data_cols) do
    [:id, :confirmed_at, :email, :name, :username, :attended, :roles, :view_url, :edit_url, :DT_RowId, :confirmed]
  end
  let(:view) do
    view = double(
      'view',
      params: {
        'draw'    => '1',
        'columns' => {
          '0' => {
            'data'       => 'id',
            'name'       => '',
            'searchable' => 'true',
            'orderable'  => 'true',
            'search'     => { 'value' => '', 'regex' => 'false' }
          },
          '1' => {
            'data'       => 'confirmed_at',
            'name'       => '',
            'searchable' => 'false',
            'orderable'  => 'true',
            'search'     => { 'value' => '', 'regex' => 'false' }
          },
          '2' => {
            'data'       => 'email',
            'name'       => '',
            'searchable' => 'true',
            'orderable'  => 'true',
            'search'     => { 'value' => '', 'regex' => 'false' }
          },
          '3' => {
            'data'       => 'name',
            'name'       => '',
            'searchable' => 'true',
            'orderable'  => 'true',
            'search'     => { 'value' => '', 'regex' => 'false' }
          },
          '4' => {
            'data'       => 'attended',
            'name'       => '',
            'searchable' => 'true',
            'orderable'  => 'true',
            'search'     => { 'value' => '', 'regex' => 'false' }
          },
          '5' => {
            'data'       => 'roles',
            'name'       => '',
            'searchable' => 'true',
            'orderable'  => 'true',
            'search'     => { 'value' => '', 'regex' => 'false' }
          },
          '6' => {
            'data'       => '',
            'name'       => '',
            'searchable' => 'true',
            'orderable'  => 'false',
            'search'     => { 'value' => '', 'regex' => 'false' }
          }
        },
        'order'   => { '0' => { 'column' => '0', 'dir' => 'asc' } },
        'start'   => '0',
        'length'  => '10',
        'search'  => { 'value' => '', 'regex' => 'false' },
        '_'       => '1532637360488'
      }.with_indifferent_access
    )
    allow(view).to receive(:admin_user_path) do |arg|
      "/admin/users/#{arg.to_param}"
    end
    allow(view).to receive(:edit_admin_user_path) do |arg|
      "/admin/users/#{arg.to_param}/edit"
    end
    return view
  end

  before do
    allow(AjaxDatatablesRails).to receive(:old_rails?).and_return(true)
  end

  describe 'implements AjaxDatatablesRails::Base' do
    it { is_expected.to respond_to(:view_columns) }
  end

  skip 'outputs' do
    let(:user) { User.first }
    let(:output) { user_datatable.as_json }

    before { skip('Investigate CI failures') }

    it 'recordsTotal' do
      expect(output[:recordsTotal]).to eq(1)
    end

    it 'recordsFiltered' do
      expect(output[:recordsFiltered]).to eq(1)
    end

    it 'data length' do
      expect(output[:data].length).to eq(1)
    end

    it 'has expected data columns' do
      expect(output[:data].first.keys).to eq(data_cols)
    end

    context 'data columns:' do
      let(:user_data) { output[:data].first }

      it 'id' do
        expect(user_data[:id].to_i).to eq(user.id)
      end

      it 'name' do
        expect(user_data[:name]).to eq(user.name)
      end

      it 'email' do
        expect(user_data[:email]).to eq(user.email)
      end

      it 'confirmed_at' do
        expect(Date.parse(user_data[:confirmed_at])).to eq(user.confirmed_at.to_date)
      end

      it 'attended' do
        expect(user_data[:attended].to_i).to eq(user.attended_count)
      end

      it 'roles' do
        expect(user_data[:roles]).to eq('None')
      end
    end
  end
end

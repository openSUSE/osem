# frozen_string_literal: true

require 'spec_helper'

describe FormatHelper, type: :helper do

  describe 'markdown' do
    it 'should return empty string for nil' do
      expect(markdown(nil)).to eq ''
    end

    it 'should return HTML for header markdown' do
      expect(Redcarpet::Markdown).to receive(:new)
      .with(
        Redcarpet::Render::HTML,
        autolink: true,
        space_after_headers: true,
        tables: true,
        strikethrough: true,
        footnotes: true,
        superscript: true
      )
      .and_call_original

      expect(markdown('# this is my header')).to eq "<h1>this is my header</h1>\n"
    end
  end
end

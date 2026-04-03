require 'rails_helper'

RSpec.describe MarkdownHelper, type: :helper do
  describe '#render_markdown' do
    it 'renders basic markdown for bold, italic, and links' do
      html = helper.render_markdown('**bold** *italic* [FastJira](https://example.com)')

      expect(html).to include('<strong>bold</strong>')
      expect(html).to include('<em>italic</em>')
      expect(html).to include('<a href="https://example.com">FastJira</a>')
    end

    it 'renders fenced code blocks with syntax highlighting wrapper' do
      markdown = <<~MD
        ```ruby
        puts "hello"
        ```
      MD

      html = helper.render_markdown(markdown)

      expect(html).to include('class="highlight"')
      expect(html).to include('language-ruby')
    end

    it 'strips unsafe script tags' do
      html = helper.render_markdown("Hello<script>alert('xss')</script>World")

      expect(html).not_to include('<script>')
      expect(html).to include('Hello')
      expect(html).to include('World')
    end

    it 'returns empty string for nil or blank input' do
      expect(helper.render_markdown(nil)).to eq('')
      expect(helper.render_markdown('')).to eq('')
      expect(helper.render_markdown('   ')).to eq('')
    end

    it 'renders markdown tables' do
      markdown = <<~MD
        | Name | Status |
        | ---- | ------ |
        | API  | Done   |
      MD

      html = helper.render_markdown(markdown)

      expect(html).to include('<table>')
      expect(html).to include('<thead>')
      expect(html).to include('<tbody>')
      expect(html).to include('<td>API</td>')
    end
  end
end

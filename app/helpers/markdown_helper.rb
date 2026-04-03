module MarkdownHelper
  ALLOWED_MARKDOWN_TAGS = %w[
    p br strong em b i a ul ol li
    h1 h2 h3 h4 h5 h6
    blockquote pre code span
    table thead tbody tr th td
    hr del img div
  ].freeze

  ALLOWED_MARKDOWN_ATTRIBUTES = %w[href title src alt class id].freeze

  class HTMLWithRouge < Redcarpet::Render::HTML
    def block_code(code, language)
      lexer = if language.present?
        Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText
      else
        Rouge::Lexers::PlainText
      end

      formatter = Rouge::Formatters::HTML.new
      highlighted = formatter.format(lexer.lex(code))
      %(<div class="highlight"><pre><code class="language-#{ERB::Util.html_escape(language.to_s)}">#{highlighted}</code></pre></div>)
    end
  end

  def render_markdown(text)
    return "".html_safe if text.blank?

    renderer = HTMLWithRouge.new(filter_html: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      autolink: true,
      tables: true,
      strikethrough: true,
      no_intra_emphasis: true,
      highlight: true
    )

    sanitized = sanitize(
      markdown.render(text),
      tags: ALLOWED_MARKDOWN_TAGS,
      attributes: ALLOWED_MARKDOWN_ATTRIBUTES
    )

    sanitized.html_safe
  end
end

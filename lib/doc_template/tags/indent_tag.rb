# frozen_string_literal: true

module DocTemplate
  module Tags
    class IndentTag < BaseTag
      TAG_NAME = 'indent'
      TEMPLATES = {
        default: 'indent.html.erb',
        gdoc: 'gdoc/indent.html.erb'
      }.freeze

      def parse(node, opts = {})
        @node = node
        @opts = opts
        @content = parse_template({ content: parsed_content }, template_name(opts))
        replace_tag node
        self
      end

      private

      attr_reader :node, :opts

      def parsed_content
        content_without_tag = node.to_html.sub FULL_TAG, ''
        html = parse_nested content_without_tag, opts

        if gdoc?(opts)
          nodes = Nokogiri::HTML.fragment html
          if (el = nodes.at_css('p'))
            el['class'] = 'u-ld-indented'
            html = nodes.to_s
          end
        end

        html
      end
    end
  end

  Template.register_tag(Tags::IndentTag::TAG_NAME, Tags::IndentTag)
end

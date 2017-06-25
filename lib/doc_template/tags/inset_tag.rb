module DocTemplate
  module Tags
    class InsetTag < BlockTag
      STYLES_REGEXP = {
        bold: /font-weight:[6-9]00/i,
        italic: /font-style:italic/i
      }.freeze
      TAG_NAME = 'inset'.freeze

      def parse(node, opts = {})
        nodes = block_nodes(node) { |n| preserve_styles n }
        content = parse_nested nodes.map(&:to_html).join, opts
        nodes.each(&:remove)
        @result = node.replace "<div class='o-ld-inset'>#{content}</div>"
        self
      end

      private

      def preserve_styles(node)
        node.children.each do |el|
          el['class'] = el['class'].to_s + ' text-bold' if el['style'] =~ STYLES_REGEXP[:bold]
          el['class'] = el['class'].to_s + ' text-italic' if el['style'] =~ STYLES_REGEXP[:italic]
        end
        node
      end
    end
  end

  Template.register_tag(Tags::InsetTag::TAG_NAME, Tags::InsetTag)
end

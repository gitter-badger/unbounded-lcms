module DocTemplate
  module Tags
    class CalloutTag < BaseTag
      TAG_NAME = 'callout'.freeze
      TEMPLATE = 'callout.html.erb'.freeze

      def parse(node, opts = {})
        table = node.ancestors('table').first
        return self unless table.present?
        header, content = fetch_content(table)

        params = {
          content: content,
          header: header,
          subject: opts[:metadata].resource_subject
        }
        new_content = parse_template(params, TEMPLATE)
        parsed_content = parse_nested(new_content, opts)
        @result = (previous_non_empty(table.previous_element) || table).before(parsed_content)
        table.remove
        self
      end

      private

      def previous_non_empty(node)
        while node
          break unless node.content.squish.blank?
          node = node.previous_element
        end
        node
      end

      def fetch_content(node)
        [node.at_xpath('.//tr[2]/td').try(:content) || '',
         node.at_xpath('.//tr[3]/td').try(:inner_html) || '']
      end
    end

    Template.register_tag(Tags::CalloutTag::TAG_NAME, CalloutTag)
  end
end

module DocTemplate
  class GroupTag < Tag
    TAG_NAME = 'group'.freeze
    TEMPLATE = 'h2-header.html.erb'.freeze

    def parse(node, opts = {})
      group = opts[:agenda].group_by_id(opts[:value].parameterize)
      return parse_ela6(node, group) if ela6?(opts[:metadata])
      node.replace(parse_template(group, TEMPLATE))
      @result = node
      self
    end

    private

    def parse_ela6(node, group)
      table = node.ancestors('table')
      @result = node.ancestors('table').before(parse_template(group, TEMPLATE))
      # remove table if it was last group without sections in a table
      node.ancestors('tr').first.next_element ? node.remove : table.remove
      self
    end
  end

  Template.register_tag(GroupTag::TAG_NAME, GroupTag)
end

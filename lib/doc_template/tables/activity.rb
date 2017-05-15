module DocTemplate
  module Tables
    class Activity < Base
      HEADER_LABEL = 'activity-metadata'.freeze
      HTML_VALUE_FIELDS = %w(activity-metacognition activity-guidance).freeze

      def parse(fragment)
        placed_sections = []
        path = ".//table/*/tr[1]/td//*[case_insensitive_equals(text(),'#{HEADER_LABEL}')]"
        [].tap do |result|
          fragment.xpath(path, XpathFunctions.new).each do |el|
            table = el.ancestors('table').first
            data = fetch table

            # Places activity type tags
            # Places activity type tags
            value = data['activity-title'].parameterize
            header = "<p><span>[#{::DocTemplate::Tags::ActivityMetadataTypeTag::TAG_NAME}: #{value}]</span></p>"
            table.add_next_sibling header

            # Places new tags to markup future content injection
            # Inserts only once
            if placed_sections.include?(data['section-title'])
              table.remove
            else
              placed_sections << data['section-title']
              value = data['section-title'].parameterize
              header = "<p><span>[#{::DocTemplate::Tags::ActivityMetadataSectionTag::TAG_NAME}: #{value}]</span></p>"
              table.replace header
            end

            result << data
          end
        end
      end
    end
  end
end

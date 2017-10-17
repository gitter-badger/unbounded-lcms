# frozen_string_literal: true

module DocTemplate
  module Objects
    class SectionsMetadata
      include Virtus.model
      include DocTemplate::Objects::TocHelpers

      class Section
        include Virtus.model
        include DocTemplate::Objects::MetadataHelpers

        attribute :children, Array[DocTemplate::Objects::ActivityMetadata::Activity]
        attribute :summary, String
        attribute :time, Integer, default: 0
        attribute :title, String

        # aliases to build toc
        attribute :handled, Boolean, default: false
        attribute :anchor, String, default: ->(a, _) { "#{a.idx} #{a.title}".parameterize }
        attribute :idx, Integer
        attribute :level, Integer, default: 1

        attribute :material_ids, Array[Integer], default: []

        def add_activity(activity)
          self.time += activity.time.to_i
          activity.handled = true
          children << activity
        end

        def section_standard_info
          standard_info lesson_standard
        end
      end

      attribute :children, Array[Section]
      attribute :idx, Integer

      def self.build_from(data)
        copy = Marshal.load Marshal.dump(data)
        sections = copy.map do |metadata|
          metadata.transform_keys { |k| k.to_s.gsub('section-', '').underscore }
        end
        new(set_index(children: sections))
      end

      def add_break
        idx = children.index { |c| !c.handled } || -1
        section = Section.new(title: 'Foundational Skills Lesson', anchor: 'optbreak', time: 0, children: [])
        children.insert(idx - 1, section)
      end
    end
  end
end

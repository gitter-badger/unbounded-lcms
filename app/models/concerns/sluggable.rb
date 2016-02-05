module Sluggable
  extend ActiveSupport::Concern

  ELA_ROOT_TITLE  = 'ELA Curriculum Map'
  MATH_ROOT_TITLE = 'Math Curriculum Map'

  PREFIXES   = { ELA_ROOT_TITLE => 'ela', MATH_ROOT_TITLE => 'math' }
  SUBJECTS   = { ELA_ROOT_TITLE => 'English Language Arts', MATH_ROOT_TITLE => 'Mathematics' }
  UNIT_SLUGS = { ELA_ROOT_TITLE => 'unit', MATH_ROOT_TITLE => 'topic' }

  included do
    after_save :generate_slugs, if: :curriculum_map?
  end

  def ela?
    root_collection_title == ELA_ROOT_TITLE
  end

  def generate_slugs
    return unless curriculum_map?

    root = root_collection

    return unless root

    @root_title = root.title

    generate_slug(tree.root, PREFIXES[@root_title])
  end

  def math?
    root_collection_title == MATH_ROOT_TITLE
  end

  def root_collection
    @root_collection ||= ResourceCollection.
                           select('resources.title').
                           joins(resource: { resource_children: :child }).
                           where(resources: { title: [ELA_ROOT_TITLE, MATH_ROOT_TITLE] }).
                           where(resource_children: { child: resource }).
                           first
  end

  def root_collection_title
    root_collection.title rescue nil
  end

  private
    def generate_slug(node, prefix)
      slug =
        case node.level
        when 0 then grade_slug(node)
        when 1 then module_slug(node)
        when 2 then unit_slug(node)
        when 3 then lesson_slug(node)
        end

      full_slug = "#{prefix}/#{slug}"

      if (url_slug = ResourceSlug.find_by(resource_collection: self, resource_id: node.content.id))
        url_slug.update_column(:value, full_slug)
      elsif (url_slug = ResourceSlug.find_by(resource_collection: self, value: full_slug))
        url_slug.update_column(:resource_id, node.content.id)
      else
        ResourceSlug.create!(resource: node.content, resource_collection: self, value: full_slug)
      end

      node.children.each { |n| generate_slug(n, full_slug) }
    end

    def grade_slug(node)
      subject = SUBJECTS[@root_title]

      node.content.title.
        gsub(subject, '').
        strip.
        gsub('  ', ' ').
        gsub(' ', '-').
        downcase
    end

    def lesson_slug(node)
      "lesson-#{node.position + 1}"
    end

    def module_slug(node)
      "module-#{node.position + 1}"
    end

    def unit_slug(node)
      if (short_title = node.content.short_title).present?
        short_title.
          gsub(',', '').
          gsub(' ', '-').
          downcase 
      else
        slug = UNIT_SLUGS[@root_title]
        "#{slug}-#{node.position + 1}"
      end
    end
end
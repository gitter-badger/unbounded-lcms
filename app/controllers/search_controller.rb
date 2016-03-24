class SearchController < ApplicationController
  include Filterbar
  include Pagination

  before_action :find_resources
  before_action :set_props

  def index
    respond_to do |format|
      format.html
      format.json { render json: @props }
    end
  end

  protected
    def find_resources
      qset = Curriculum.trees.with_resources.includes(:resource_item, :curriculum_type)
      unless search_term.blank?
        resource_ids = Resource.search(search_term, limit: 100).results.map {|r| r.id.to_i }
        qset = qset.where(item_id: resource_ids).order_as_specified(item_id: resource_ids)
      end

      @resources = qset.where_subject(subject_params)
                 .where_grade(grade_params)
                 .paginate(pagination_params.slice(:page, :per_page))
                 .order('resources.created_at desc')
    end

    def set_props
      @props = serialize_with_pagination(@resources,
        pagination: pagination_params,
        each_serializer: CurriculumResourceSerializer
      )
      @props.merge!(filterbar_props)
    end
end
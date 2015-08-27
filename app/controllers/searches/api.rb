require 'content/models'
require 'content/search'

module Searches
  class Api
    attr_reader :operation, :results

    def initialize(params)
      limit = params[:limit].try(:to_i) || 100
      page = params[:page].try(:to_i) || 1

      search_definition = Content::Search::Esbuilder.build do
        size limit
        from (page - 1) * limit

        query do
          bool do
            must { term 'hidden' => false }

            if params[:query]
              must do
                bool do
                  should { match 'title' => { query: params[:query], boost: 2 } }
                  should { match 'description' => { query: params[:query], boost: 2 } }
                  should { match '_all' => params[:query] }
                end
              end
            elsif params[:title]
              must do
                match 'title' => params[:title]
              end
            end

            if params['language']
              must do
                nested do
                  path 'languages'
                  query do 
                    match 'languages.name.raw' => params[:language]
                  end
                end
              end
            end

            if params['publisher']
              must do
                nested do
                  path 'identities'
                  query do 
                    bool do
                      must { match 'identities.name.raw' => params[:publisher] }
                      must { term 'identities.identity_type' => 'publisher' }
                    end
                  end
                end
              end
            end

            if params['alignment']
              must do
                nested do
                  path 'alignments'
                  query do 
                    match 'alignments.name.raw' => params[:alignment]
                  end
                end
              end
            end

            if params['resource_type']
              must do
                nested do
                  path 'resource_types'
                  query do 
                    match 'resource_types.name.raw' => params[:resource_type]
                  end
                end
              end
            end

            if params['subject']
              must do
                nested do
                  path 'subjects'
                  query do 
                    match 'subjects.name.raw' => params[:subject]
                  end
                end
              end
            end
          end
        end
      end.to_hash

      Rails.logger.debug("Constructed Elasticsearch search definition: #{search_definition.to_json}")

      @operation = Content::Models::Lobject.search(search_definition)
      @results = operation.map(&:_source)
    end
  end
end

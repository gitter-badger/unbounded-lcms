module WordFilesProcessor
  class ResourceHandler
    include Tools

    attr_reader :file, :context

    def initialize(file, context)
      @file = file
      @context = context.to_h.merge(@file.filename_fragments)
      find!
    end

    def breadcrumbs
      @breadcrumb_short_title ||= begin
        breadcrumb = []
        breadcrumb << subject_abbrv
        breadcrumb << "G#{context[:grade]}"  if context[:grade]
        breadcrumb << "M#{context[:module]}" if context[:module]
        breadcrumb << "U#{context[:unit]}"   if context[:unit]
        breadcrumb << "L#{context[:lesson]}" if context[:lesson]
        breadcrumb.join(' / ')
      end
    end

    def subject_abbrv
      (/math/i).match(context[:subject]) ? 'MA' : 'EL'
    end

    def find_by_breadcrumbs
      Curriculum.trees.find_by(breadcrumb_short_title: breadcrumbs)
    end

    def find_by_introspection
      # unnecessary for now. Look on https://github.com/learningtapestry/unbounded/issues/411 for more info on this
      nil
    end

    def find!
      @curriculum = find_by_breadcrumbs || find_by_introspection
      @resource = @curriculum.resource
    end

    def attrs
      {
        curriculum_id:  @curriculum.id,
        resource_id:    @resource.id,
        resource_title: @resource.title,
        breadcrumbs:    breadcrumbs,
        filename:       @file.basename,
        dir:            @file.filepath.dirname
      }
    end

    def report(extras)
      csv attrs.merge(extras)
    end

    def pdf_dir
      @@pdf_dir ||= begin
        pdf_files_dir = ENV['PDF_FILES_DIR']
        pdf_files_dir ? Pathname.new(pdf_files_dir) : nil
      end
    end

    def create_db_assoc!(s3_file=nil)
      s3_file ||= @file
      title = s3_file.basename.gsub(/\.\w+$/, '') # file name without extension
      @resource.downloads << Download.create(file: s3_file.filepath.open, title: title)
      if pdf_dir
        pdf_filename = pdf_dir.join(s3_file.basename.to_s.gsub('.docx', '.pdf'))
        @resource.downloads << Download.create(file: pdf_filename.open, title: title)
      end
      @resource.save!
    end

    def remove_all!
      ResourceDownload.where(resource_id: @resource.id).delete_all if @resource
    end
  end
end

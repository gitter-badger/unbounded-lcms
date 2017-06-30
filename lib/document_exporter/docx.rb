module DocumentExporter
  class Docx
    def initialize(document)
      @document = DocumentPresenter.new document
    end

    def export
      PandocRuby.convert content, from: :html, to: :docx
    end

    private

    def content
      # Using backport of Rails 5 Renderer here
      @content ||= ApplicationController.render(
        layout: 'ld_docx',
        locals: { :@document => @document },
        template: 'documents/docx/export'
      )
    end
  end
end

module Content
  module Importers
    class SubtitlesImporter
      include ActiveModel::Model
      include Content::Models

      COLUMNS_COUNT     = 5
      DESCRIPTION_INDEX = 4
      ID_INDEX          = 1
      SUBTITLE_INDEX    = 3

      attr_accessor :file, :lobjects

      validates :file, presence: true
      validate :spreadsheet_format

      def initialize(file = nil)
        @file = file
        if @file.present?
          @doc = Roo::Spreadsheet.open(file.path) rescue nil
        end
      end

      def import
        if valid?
          sheet = Roo::Spreadsheet.open(file.path)

          @lobjects = []

          (2..sheet.last_row).each do |i|
            row = sheet.row(i)
            description = row[DESCRIPTION_INDEX]
            subtitle = row[SUBTITLE_INDEX]
            if description.present? || subtitle.present?
              if (lobject = Lobject.find_by_id(row[ID_INDEX])).present?
                if description.present?
                  if lobject_description = lobject.lobject_descriptions.first
                    lobject_description.update_column(:description, description)
                  else
                    lobject.lobject_descriptions.create!(description: description)
                  end
                end

                if subtitle.present?
                  if lobject_title = lobject.lobject_titles.first
                    lobject_title.update_column(:subtitle, subtitle)
                  else
                    lobject.lobject_titles.create!(subtitle: subtitle)
                  end
                end

                @lobjects << lobject
              end
            end
          end
        end
      end

      private
        def spreadsheet_format
          return if file.blank?

          if @doc
            cols_count = @doc.row(1).size
            errors.add(:file, :incorrect_format, count: cols_count, limit: COLUMNS_COUNT) unless cols_count == COLUMNS_COUNT
          else
            errors.add(:file, :incorrect_type)
          end
        end
    end
  end
end
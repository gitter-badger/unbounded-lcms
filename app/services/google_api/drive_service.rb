# frozen_string_literal: true

module GoogleApi
  class DriveService < Base
    FOLDER_ID   = ENV['GOOGLE_APPLICATION_FOLDER_ID']
    MIME_FOLDER = 'application/vnd.google-apps.folder'
    MIME_FILE   = 'application/vnd.google-apps.document'

    def copy(file_ids)
      folder_id = parent
      file_ids.each do |id|
        service.get_file(id, fields: 'name') do |f, err|
          if err.present?
            Rails.logger.error "Failed to get file with #{id}, #{err.message}"
          else
            service.copy_file(id, Google::Apis::DriveV3::File.new(name: f.name, parents: [folder_id]))
          end
        end
      end
      folder_id
    end

    def create_folder(folder_name, parent_id = FOLDER_ID)
      if (files = folder_query(folder_name, parent_id).files).any?
        return files[0].id
      end

      metadata = Google::Apis::DriveV3::File.new(
        name: folder_name,
        mime_type: MIME_FOLDER,
        parents: [parent_id]
      )
      service.create_file(metadata).id
    end

    def file_exists?(name, parent_id)
      service.list_files(
        q: "'#{parent_id}' in parents and name = '#{name}' and trashed = false",
        fields: 'files(id)'
      ).files&.first&.id
    end

    def file_id
      @file_id ||= begin
        file_name = document.base_filename
        response = service.list_files(
          q: "'#{parent}' in parents and name = '#{file_name}' and mimeType = '#{MIME_FILE}' and trashed = false",
          fields: 'files(id)'
        )
        return nil if response.files.empty?
        unless response.files.size == 1
          Rails.logger.warn "Multiple files: more than 1 file with same name: #{file_name}"
        end
        response.files[0].id
      end
    end

    def parent
      @parent ||=
        begin
          subfolders = (options[:subfolders] || []).unshift(options[:gdoc_folder] || document.gdoc_folder)
          parent_folder = FOLDER_ID
          subfolders.each do |folder|
            parent_folder = subfolder(folder, parent_folder)
          end
          parent_folder
        end
    end

    private

    def folder_query(folder_name, parent_id)
      service.list_files(
        q: "'#{parent_id}' in parents and name = '#{folder_name}' and mimeType = '#{MIME_FOLDER}' and trashed = false",
        fields: 'files(id)'
      )
    end

    def subfolder(folder_name, parent_id = FOLDER_ID)
      response = folder_query folder_name, parent_id
      return create_folder(folder_name, parent_id) if response.files.empty?
      Rails.logger.warn "Multiple folders: more than 1 folder with same name: #{folder_name}" unless response.files.size == 1
      response.files[0].id
    end
  end
end

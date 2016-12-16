class DownloadsController < ApplicationController
  include ActionController::Live
  include AnalyticsTracking

  before_action :init_download
  before_action :init_resource, only: :preview
  before_action :ga_track, except: :pdf_proxy

  def show
    redirect_to @download.attachment_url
  end

  def preview
    RestClient.head(@download.attachment_url)
  rescue RestClient::ExceptionWithResponse => e
    render text: e.response, status: '404'
  end

  def pdf_proxy
    uri = URI(@download.attachment_url)
    response.headers['Content-Disposition'] = 'inline'
    response.headers['Content-Type'] = 'application/pdf'
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      s3_request = Net::HTTP::Get.new(uri)
      http.request(s3_request) do |s3_response|
        s3_response.read_body do |chunk|
          response.stream.write(chunk)
        end
      end
    end
  ensure
    response.stream.close
  end

  private

  def init_download
    resource_download = ResourceDownload.find(params[:id])
    @resource = GenericPresenter.new(resource_download.resource)
    @download = resource_download.download
  end

  def init_resource
    if @resource.generic?
      @color_code = @resource.color_code(@resource.grade_avg)
    else
      curriculum = @resource.first_tree
      @color_code = @resource.color_code(curriculum.try(:grade_color_code))
      @curriculum = CurriculumPresenter.new(curriculum)
    end
  end

  def ga_track
    action = show_with_slug_path(ResourceSlug.find(params[:slug_id]).value) if params[:slug_id]
    label = @download.attachment_url
    ga_track_download(action: action, label: label)
  end
end

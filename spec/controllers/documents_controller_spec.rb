# frozen_string_literal: true

require 'rails_helper'

describe DocumentsController do
  let(:document) { create :document }

  before { sign_in create(:user) }

  # TODO: Need to re-new that specs as was done for PDF generation
  xdescribe '#export_gdoc' do
    let(:exporter) { instance_double 'DocumentExporter::GDoc::Base', url: url }
    let(:file_id) { 'fileid' }
    let(:metadata) { instance_double 'DocTemplate::Objects::BaseMetadata', title: title }
    let(:title) { 'title' }
    let(:url) { 'url' }

    # before do
    #   create :document_part, document: document, part_type: 'layout'
    #
    #   allow(controller).to receive(:obtain_google_credentials)
    #   allow(DocTemplate::Objects::BaseMetadata).to receive(:build_from).and_return(metadata)
    #   allow(DocumentExporter::GDoc::Base).to receive_message_chain(:new, :export).and_return(exporter)
    # end

    subject { get :export_gdoc, id: document.id }

    it 'renders document content into a string' do
      expect(controller).to receive(:render).with(json: { url: nil }, status: :ok)
      subject
    end

    it 'calls DocumentExporter' do
      expect(DocumentExporter::GDoc::Base).to receive_message_chain(:new, :export)
      subject
    end

    it 'redirects to the final Google Doc' do
      expect(subject).to redirect_to url
    end
  end

  context 'PDF generation' do
    let(:response) { JSON.parse subject.body }

    describe '#export' do
      let(:excludes) { %w(1 2) }
      let(:job_id) { '10' }
      let(:job_options) do
        {
          excludes: excludes,
          content_type: type
        }
      end
      let(:type) { 'type' }
      let(:url) { 'url' }

      before do
        allow_any_instance_of(DocumentPresenter).to receive(:pdf_filename)
        allow(S3Service).to receive(:url_for).and_return(:url)
        allow(LessonGeneratePdfJob).to receive_message_chain(:perform_later, :job_id).and_return(job_id)
      end

      subject { post :export, id: document.id, type: type, excludes: excludes, context: 'pdf' }

      it 'calls S3Service' do
        expect(S3Service).to receive(:url_for)
        subject
      end

      it 'starts PDF generation job' do
        expect(LessonGeneratePdfJob).to receive(:perform_later).with(document, hash_including(job_options))
        subject
      end

      it { expect(response['id']).to eq job_id }

      it { expect(response['url']).to eq url }

      context 'when no excludes passed' do
        let(:excludes) { [] }
        let(:pregenerated_url) { 'url' }

        before { document.update links: { "pdf_#{type}" => pregenerated_url } }

        it 'returns url for the pregenerated PDF with passed in type' do
          expect(response['url']).to eq pregenerated_url
        end
      end

      context 'when no type param passed' do
        let(:type) { nil }

        it { expect(subject.response_code).to eq 400 }
      end
    end

    describe '#export_status' do
      let(:job_id) { '10' }

      before { allow(LessonGeneratePdfJob).to receive(:find) }

      subject { get :export_status, context: 'pdf', id: document.id, jid: job_id }

      it 'looks up job queue for the job' do
        expect(LessonGeneratePdfJob).to receive(:find).with(job_id)
        subject
      end

      context 'when job is finished' do
        before { allow(LessonGeneratePdfJob).to receive(:find) }

        it { expect(response['ready']).to be_truthy }
      end

      context 'when job is still running or queued' do
        before { allow(LessonGeneratePdfJob).to receive(:find).and_return(1) }

        it { expect(response['ready']).to be_falsey }
      end
    end
  end
end

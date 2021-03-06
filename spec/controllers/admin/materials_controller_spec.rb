# frozen_string_literal: true

require 'rails_helper'

describe Admin::MaterialsController do
  let(:user) { create :admin }

  before { sign_in user }

  describe '#destroy' do
    let!(:material) { create :material }

    subject { delete :destroy, id: material.id }

    it { expect { subject }.to change { Material.count }.by(-1) }

    context 'when there was custom filter' do
      let(:query) { 'filter' }

      subject { delete :destroy, id: material.id, query: query }

      it { is_expected.to redirect_to admin_materials_path(query: query) }
    end
  end

  describe '#index' do
    subject { get :index }

    it { is_expected.to be_success }

    it { is_expected.to render_template :index }
  end

  describe '#new' do
    before { allow(controller).to receive(:obtain_google_credentials) }

    subject { get :new }

    it 'initiates the form object' do
      expect(MaterialForm).to receive(:new)
      subject
    end

    it { is_expected.to render_template :new }
  end
end

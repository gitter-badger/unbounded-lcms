require 'rails_helper'

describe Admin::CurriculumsController do
  let(:user) { create :admin }

  before { sign_in user }

  describe '#edit' do
    subject { get :edit }

    it { is_expected.to be_success }
    it { is_expected.to render_template :edit }
  end
end

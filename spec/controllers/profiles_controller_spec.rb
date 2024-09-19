require "rails_helper"

RSpec.describe ProfilesController, type: :controller do
  let(:member) { FactoryBot.create(:member) }

  describe 'patch' do
    before { sign_in member }
    it 'translate ja job perform' do
      patch :update, params: { id: member.profile.to_param, profile: { login: "satou" } }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(member.profile)
      expect(TranslateJaProfJob.jobs.size).to eq 1
    end
  end
end

